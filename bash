# generate 9:16 short form (reframe & crop center; adjust as needed)
ffmpeg -i input.mp4 -vf "scale=1080:-2, crop=1080:1920" -c:v libx264 -preset fast -b:v 2500k -maxrate 3000k -bufsize 5000k -c:a aac -b:a 128k short_1080x1920.mp4

# HLS multi-bitrate
ffmpeg -i input.mp4 \
  -filter:v "scale=w=1280:h=-2" -c:v libx264 -b:v 3000k -maxrate 3300k -bufsize 6000k -c:a aac -b:a 128k -f hls -hls_time 6 -hls_playlist_type vod -hls_segment_filename 'seg_1080p_%03d.ts' 1080p.m3u8
