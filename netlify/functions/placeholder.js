exports.handler = async function(event, context) {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Netlify function placeholder is working.' })
  };
};
