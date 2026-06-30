const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const ROOT = path.resolve(__dirname, '..');
const SCHEMA_SQL = path.join(ROOT, 'schema.sql');

function loadSchema() {
  return fs.readFileSync(SCHEMA_SQL, 'utf8');
}

function normalizeSql(sql) {
  return sql
    .replace(/\r\n/g, '\n')
    .replace(/\t/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function transformCheckAny(statement) {
  return statement.replace(/CHECK \(([^=]+)= ANY \(ARRAY\[([^\]]+)\]\)\)/gi, (match, lhs, values) => {
    const items = values
      .split(',')
      .map(item => item.replace(/::[a-z ]+/gi, '').trim())
      .map(item => item.replace(/^\s*'/, "'").replace(/'\s*$/, "'"))
      .join(', ');
    return `CHECK (${lhs.trim()} IN (${items}))`;
  });
}

function transformForSqlite(rawSchema) {
  let schema = rawSchema;
  schema = schema.replace(/public\./g, '');
  schema = schema.replace(/auth\.users/gi, 'auth_users');
  schema = schema.replace(/timestamp with time zone/gi, 'TEXT');
  schema = schema.replace(/DEFAULT now\(\)/gi, 'DEFAULT (CURRENT_TIMESTAMP)');
  schema = schema.replace(/DEFAULT gen_random_uuid\(\)/gi, "DEFAULT (lower(hex(randomblob(16))))");
  schema = schema.replace(/CREATE TABLE ([^\s]+)/gi, 'CREATE TABLE IF NOT EXISTS $1');
  schema = schema.replace(/::text/gi, '');
  schema = transformCheckAny(schema);
  return schema;
}

function splitSqlStatements(sql) {
  const statements = [];
  let current = '';
  let inString = false;
  let prevChar = '';

  for (const char of sql) {
    current += char;
    if (char === "'" && prevChar !== '\\') {
      inString = !inString;
    }
    if (char === ';' && !inString) {
      const stmt = current.trim();
      if (stmt) statements.push(stmt);
      current = '';
    }
    prevChar = char;
  }
  const last = current.trim();
  if (last) statements.push(last);
  return statements;
}

function runLocalMigration() {
  console.log('Local SQLite migration is temporarily disabled. Skipping for now.');
}

async function runRemoteMigration() {
  const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error('SUPABASE_DB_URL or DATABASE_URL must be set for remote migration.');
  }

  const raw = loadSchema();
  const statements = splitSqlStatements(raw).map(stmt => {
    return stmt.replace(/CREATE TABLE public\./gi, 'CREATE TABLE IF NOT EXISTS public.');
  });

  const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });
  await client.connect();
  try {
    for (const statement of statements) {
      if (!statement) continue;
      try {
        await client.query(statement);
      } catch (err) {
        console.error('Remote migration failed on statement:', statement);
        throw err;
      }
    }
    console.log('Remote Supabase migration completed.');
  } finally {
    await client.end();
  }
}

async function main() {
  const args = process.argv.slice(2);
  const isLocal = args.includes('--local');
  const isRemote = args.includes('--remote');
  const isBuild = args.includes('--build');

  if (!isLocal && !isRemote && !isBuild) {
    console.error('Usage: node migrate.js --local | --remote | --build');
    process.exit(1);
  }

  if (isBuild) {
    const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
    if (connectionString) {
      console.log('Remote database configured, running remote migration.');
      await runRemoteMigration();
    } else {
      console.log('No remote database configured. Skipping schema migration for build.');
    }
    return;
  }

  if (isLocal) {
    runLocalMigration();
  }
  if (isRemote) {
    await runRemoteMigration();
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
