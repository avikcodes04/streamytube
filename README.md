# 🎥 STREAMYTUBE — Full-Stack Video Streaming Platform

A backend-first video streaming system built to explore real-world system design, cloud architecture, and asynchronous processing pipelines.

> ⚠️ This project focuses on backend architecture, scalability, and cloud workflows — not UI polish.

---

## 🚀 Overview

STREAMYTUBE is a full-stack video streaming platform designed to simulate how modern media platforms handle uploads, processing, and delivery at scale.

The system emphasizes:

* Backend orchestration
* Cloud-native architecture
* Asynchronous video processing
* Scalable media delivery

---

## 🧠 Key Learnings

* Designing distributed systems using AWS services
* Implementing async workflows using queues (SQS)
* Building containerized services with Docker
* Managing authentication with AWS Cognito
* Handling large media pipelines (upload → process → deliver)

---

## 🏗️ Architecture

### 🔧 Backend

* FastAPI — core backend service
* PostgreSQL (Docker) — stores users & video metadata
* Docker — containerized services

### 🔐 Authentication

* AWS Cognito — user authentication & JWT handling

### ☁️ Media Storage & Delivery

* AWS S3 — video + thumbnail storage
* AWS CloudFront — CDN for fast delivery

### 🔄 Async Processing

* AWS SQS — job queue for video processing
* FFmpeg Transcoder (Docker container)
* AWS ECS + ECR — container orchestration & deployment

### 📱 Frontend

* Flutter (BLoC) — handles auth, upload, playback

---

## 🔁 End-to-End Flow

1. User authenticates via Cognito
2. Uploads video using pre-signed S3 URL
3. Upload event triggers SQS job
4. Transcoder service processes video (FFmpeg)
5. Processed video stored in S3
6. Delivered globally via CloudFront CDN
7. Metadata managed by FastAPI + PostgreSQL

---

## 📸 Screenshots / Demo

🎥 Watch the demo here:
https://www.linkedin.com/posts/avik-sinha-a6a336251_%F0%9D%90%81%F0%9D%90%AE%F0%9D%90%A2%F0%9D%90%A5%F0%9D%90%AD-%F0%9D%90%9A-%F0%9D%90%9F%F0%9D%90%AE%F0%9D%90%A5%F0%9D%90%A5-%F0%9D%90%AC%F0%9D%90%AD%F0%9D%90%9A%F0%9D%90%9C%F0%9D%90%A4-%F0%9D%90%AF-activity-7424728453154881536-BTFr?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAAD4p1XIBietjRoROXY24Rc1ovhSyF4VUJU0

> A short walkthrough demonstrating video upload, processing pipeline, and playback flow.

## ⚙️ Setup Instructions

### Prerequisites

* Docker
* AWS account (S3, SQS, Cognito configured)

### Run locally

```bash
git clone <your-repo-link>
cd streamytube

docker-compose up --build
```

---

## 🔮 Future Improvements

* Video recommendations system
* Like / comment / subscription features
* Adaptive bitrate streaming (HLS/DASH)
* Monitoring with Prometheus & Grafana

---

## 👨‍💻 Author

Avik Sinha
📧 [aviksinha941@gmail.com](mailto:aviksinha941@gmail.com)
🔗 https://www.linkedin.com/in/avik-sinha-a6a336251/

---
