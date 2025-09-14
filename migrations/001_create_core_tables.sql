-- 001_create_core_tables.sql
BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  hashed_password TEXT,
  display_name VARCHAR(100),
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  last_active TIMESTAMP WITH TIME ZONE
);

CREATE TABLE channels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE videos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  channel_id UUID REFERENCES channels(id) ON DELETE SET NULL,
  title VARCHAR(300),
  description TEXT,
  visibility VARCHAR(20) DEFAULT 'public',
  duration_sec INTEGER,
  aspect_ratio VARCHAR(10),
  tags TEXT[],
  thumbnail_url TEXT,
  hls_manifest_url TEXT,
  processing_status VARCHAR(20) DEFAULT 'processing',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE short_clips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_video_id UUID REFERENCES videos(id) ON DELETE SET NULL,
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  object_key TEXT NOT NULL,
  duration_sec INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE follows (
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  followee_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  PRIMARY KEY (follower_id, followee_id)
);

CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  target_type VARCHAR(20) NOT NULL,
  target_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  target_type VARCHAR(20) NOT NULL,
  target_id UUID NOT NULL,
  parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
  target_type VARCHAR(20) NOT NULL,
  target_id UUID NOT NULL,
  reason_code VARCHAR(50),
  details TEXT,
  status VARCHAR(20) DEFAULT 'open',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes for common queries
CREATE INDEX idx_videos_owner ON videos(owner_id);
CREATE INDEX idx_videos_status ON videos(processing_status);
CREATE INDEX idx_comments_target ON comments(target_type, target_id);
CREATE INDEX idx_likes_target ON likes(target_type, target_id);

COMMIT;
