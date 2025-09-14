apiVersion: batch/v1
kind: Job
metadata:
  name: transcode-job-{{JOB_ID}}
spec:
  template:
    spec:
      containers:
      - name: transcode
        image: myregistry/ffmpeg-worker:latest
        env:
          - name: S3_BUCKET
            value: "my-upload-bucket"
          - name: JOB_PAYLOAD
            valueFrom:
              secretKeyRef:
                name: transcode-payload
                key: payload
        command: ["/bin/sh","-c","python /app/run_transcode.py --payload '$JOB_PAYLOAD' "]
      restartPolicy: Never
  backoffLimit: 3
