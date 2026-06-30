-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  username text NOT NULL UNIQUE,
  display_name text,
  avatar_url text,
  bio text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.prayers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  text text NOT NULL,
  mode text NOT NULL CHECK (mode = ANY (ARRAY['petition'::text, 'lament'::text, 'thanksgiving'::text, 'adoration'::text, 'confession'::text])),
  is_public boolean DEFAULT false,
  is_answered boolean DEFAULT false,
  testimony text,
  linked_to uuid,
  circle_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT prayers_pkey PRIMARY KEY (id),
  CONSTRAINT prayers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT prayers_linked_to_fkey FOREIGN KEY (linked_to) REFERENCES public.prayers(id),
  CONSTRAINT fk_prayers_circle FOREIGN KEY (circle_id) REFERENCES public.prayer_circles(id)
);
CREATE TABLE public.comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  prayer_id uuid NOT NULL,
  user_id uuid NOT NULL,
  text text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT comments_pkey PRIMARY KEY (id),
  CONSTRAINT comments_prayer_id_fkey FOREIGN KEY (prayer_id) REFERENCES public.prayers(id),
  CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.prayer_circles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  created_by uuid NOT NULL,
  is_private boolean DEFAULT false,
  invite_code text UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT prayer_circles_pkey PRIMARY KEY (id),
  CONSTRAINT prayer_circles_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.circle_members (
  circle_id uuid NOT NULL,
  user_id uuid NOT NULL,
  joined_at timestamp with time zone DEFAULT now(),
  role text DEFAULT 'member'::text CHECK (role = ANY (ARRAY['member'::text, 'moderator'::text, 'admin'::text])),
  CONSTRAINT circle_members_pkey PRIMARY KEY (circle_id, user_id),
  CONSTRAINT circle_members_circle_id_fkey FOREIGN KEY (circle_id) REFERENCES public.prayer_circles(id),
  CONSTRAINT circle_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.prayer_reactions (
  prayer_id uuid NOT NULL,
  user_id uuid NOT NULL,
  reaction_type text NOT NULL CHECK (reaction_type = ANY (ARRAY['praying'::text, 'amen'::text, 'healing'::text, 'mercy'::text, 'thanks'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT prayer_reactions_pkey PRIMARY KEY (prayer_id, user_id),
  CONSTRAINT prayer_reactions_prayer_id_fkey FOREIGN KEY (prayer_id) REFERENCES public.prayers(id),
  CONSTRAINT prayer_reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_data (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE,
  data jsonb NOT NULL,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_data_pkey PRIMARY KEY (id),
  CONSTRAINT user_data_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.map_intercessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  point_id integer NOT NULL,
  count integer DEFAULT 0,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT map_intercessions_pkey PRIMARY KEY (id),
  CONSTRAINT map_intercessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.prayer_feed (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  country text,
  prayer text,
  count integer,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT prayer_feed_pkey PRIMARY KEY (id),
  CONSTRAINT prayer_feed_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);