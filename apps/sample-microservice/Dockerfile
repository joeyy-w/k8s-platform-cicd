FROM golang:1.21-alpine AS builder

WORKDIR /app

# Initialize go module and copy source
RUN go mod init sample-microservice
COPY main.go .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8090
CMD ["./main"]
