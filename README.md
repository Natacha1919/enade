# Project Title: ENADE App

## Description
The ENADE App is a web application designed to facilitate the management and analysis of ENADE (National Student Performance Exam) data. This application provides features for data entry, analysis, and reporting.

## Prerequisites
- Docker
- Docker Compose
- Node.js (for local development)

## Installation
1. Clone the repository:
   ```
   git clone <repository-url>
   cd enade_app
   ```

2. Build the Docker image:
   ```
   docker-compose build
   ```

3. Start the application:
   ```
   docker-compose up
   ```

## Usage
Once the application is running, you can access it at `http://localhost:3000` (or the port specified in your `docker-compose.yml`).

## File Structure
```
enade_app
├── src
│   └── app.ts          # Main application logic
├── Dockerfile           # Dockerfile for building the application image
├── docker-compose.yml   # Docker Compose configuration
├── package.json         # npm configuration and dependencies
├── tsconfig.json        # TypeScript configuration
└── README.md            # Project documentation
```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.