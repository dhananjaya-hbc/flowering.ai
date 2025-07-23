# Flowerina - Ballerina Code Generator

A full-stack web application that generates Ballerina backend services from natural language prompts and creates interactive flowcharts to visualize the service architecture.

## ✨ Features

- **Natural Language to Code**: Convert plain English descriptions into Ballerina service code
- **Interactive Flowcharts**: Visualize service architecture with interactive ReactFlow diagrams
- **Mermaid Integration**: Export flowcharts as Mermaid diagram code
- **Template System**: Quick-start templates for common service patterns
- **Real-time Preview**: Live code editor with syntax highlighting
- **CORS-Enabled API**: Backend ready for frontend integration

## 🛠️ Tech Stack

### Frontend
- **React 19** with Vite for fast development
- **ReactFlow** for interactive flowchart visualization
- **CodeMirror** for code editing and display
- **Axios** for HTTP client communication
- **Lucide React** for beautiful icons

### Backend
- **Ballerina** HTTP service with REST API
- **CORS** configuration for cross-origin requests
- **Modular Architecture** with separate code generation and flowchart modules

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ for frontend
- Ballerina 2201.10.0+ for backend

### Frontend Setup
```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

### Backend Setup
```bash
# Navigate to backend directory
cd backend

# Run Ballerina service
bal run
```

The frontend will be available at `http://localhost:5173` and the backend API at `http://localhost:8080`.

## 📖 How It Works

### Step 1: User Input
Users enter natural language prompts describing the backend service they want to create.

**Example prompts:**
- "Create a REST API service with user authentication"
- "Build a database service for managing blog posts"
- "Generate a file upload and download service"

### Step 2: Code Generation
The Ballerina backend analyzes the prompt and:
1. Identifies key service requirements
2. Maps to appropriate service templates
3. Generates customized Ballerina code
4. Returns formatted code response

### Step 3: Flowchart Generation
The system automatically:
1. Parses the generated Ballerina code
2. Extracts services, resources, and imports
3. Creates interactive ReactFlow diagram
4. Generates Mermaid diagram syntax

### Step 4: Visualization
Users can view results in two formats:
- **Interactive View**: Draggable, zoomable ReactFlow diagram
- **Mermaid Code**: Copy-paste ready Mermaid syntax

## 🎯 Service Templates

The system includes pre-built templates for common patterns:

1. **REST API Service** - Basic HTTP endpoints with GET/POST operations
2. **Database Service** - MySQL integration with CRUD operations
3. **Message Queue Service** - Simple message queuing system
4. **File Service** - File upload/download functionality

## 🔧 API Endpoints

### Backend API (`http://localhost:8080/api`)

- `GET /health` - Health check endpoint
- `POST /generate-code` - Generate code from prompt
- `GET /templates` - Get available service templates

### Example Request
```bash
curl -X POST http://localhost:8080/api/generate-code \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Create a simple REST API with health check"}'
```

## 🏗️ Project Structure

```
flowerina/
├── frontend/
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── services/          # API integration
│   │   └── assets/            # Static assets
│   ├── package.json
│   └── vite.config.js
├── backend/
│   ├── modules/
│   │   ├── code_generator/    # Code generation logic
│   │   └── flowchart/         # Flowchart generation
│   ├── main.bal              # Main HTTP service
│   └── Ballerina.toml        # Project configuration
└── README.md
```

## 🎨 Component Architecture

### Frontend Components
- **CodeGenerator** - Main orchestrator component
- **PromptInput** - User input form with templates
- **CodeEditor** - Syntax-highlighted code display
- **FlowchartDisplay** - Interactive and Mermaid diagram views

### Backend Modules
- **code_generator** - Template matching and code generation
- **flowchart** - Code parsing and diagram data creation

## 🔄 Development Workflow

1. **Frontend Development**: `npm run dev` for hot reloading
2. **Backend Development**: `bal run` to start the service
3. **Testing**: Use the health check endpoint to verify connectivity
4. **Building**: `npm run build` for production frontend build

## 🛡️ Error Handling

The application includes comprehensive error handling:
- Network connection errors
- Invalid prompt validation
- Backend service unavailability
- Code generation failures

## 🔮 Future Enhancements

- [ ] Advanced Ballerina syntax analysis
- [ ] Multiple programming language support
- [ ] User authentication and saved projects
- [ ] Advanced flowchart customization
- [ ] Integration with external APIs
- [ ] Code export to files

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test both frontend and backend
5. Submit a pull request

## 📜 License

This project is open source and available under the MIT License.

---

**Built with ❤️ using Ballerina and React**+ Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.
