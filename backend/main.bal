import ballerina/http;

listener http:Listener httpListener = new (8081);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowHeaders: ["Content-Type", "Authorization"],
        allowMethods: ["GET", "POST", "OPTIONS"]
    }
}
service /api on httpListener {
    resource function get health() returns http:Response {
        http:Response response = new;
        response.setHeader("Access-Control-Allow-Origin", "*");
        json result = {"status": "healthy", "message": "Flowerina Backend API is running"};
        response.setJsonPayload(result);
        return response;
    }
    
    resource function post 'generate\-code(http:Request request) returns http:Response|error {
        json payload = check request.getJsonPayload();
        string userPrompt = check payload.prompt;
        
        string generatedCode = generateBallerinaCode(userPrompt);
        json flowchartData = generateFlowchartData(generatedCode, userPrompt);
        
        http:Response response = new;
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        
        json result = {"code": generatedCode, "flowchart": flowchartData};
        response.setJsonPayload(result);
        return response;
    }
    
    resource function get templates() returns http:Response {
        json result = {
            "templates": [
                {
                    "id": "rest_api", 
                    "name": "REST API Service", 
                    "description": "Complete CRUD REST API with GET, POST, PUT, DELETE operations",
                    "example": "create a REST API service for users"
                },
                {
                    "id": "database_service", 
                    "name": "Database Service", 
                    "description": "Service with MySQL database operations and connection handling",
                    "example": "create a database service with MySQL for products"
                },
                {
                    "id": "websocket_service",
                    "name": "WebSocket Service",
                    "description": "Real-time WebSocket service for chat or live communication",
                    "example": "create a WebSocket real-time chat service"
                },
                {
                    "id": "file_service",
                    "name": "File Upload/Download Service",
                    "description": "Service for handling file uploads and downloads",
                    "example": "create a file upload and download service"
                },
                {
                    "id": "auth_service",
                    "name": "Authentication Service",
                    "description": "JWT-based authentication with login and registration",
                    "example": "create an authentication service with JWT"
                }
            ]
        };
        
        http:Response response = new;
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setJsonPayload(result);
        return response;
    }
    
    resource function options 'generate\-code() returns http:Response {
        http:Response response = new;
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.statusCode = 200;
        return response;
    }
}

function generateBallerinaCode(string prompt) returns string {
    string lowercasePrompt = prompt.toLowerAscii();
    
    // Extract key information from the prompt
    string serviceName = extractServiceName(prompt);
    string[] entities = extractEntities(prompt);
    string port = extractPort(prompt);
    string primaryEntity = entities[0];
    
    if (lowercasePrompt.includes("rest api") || lowercasePrompt.includes("http service") || lowercasePrompt.includes("crud")) {
        return generateRestApiCode(serviceName, primaryEntity, port, prompt);
    } else if (lowercasePrompt.includes("database") || lowercasePrompt.includes("mysql") || lowercasePrompt.includes("sql")) {
        return generateDatabaseCode(serviceName, primaryEntity, port, prompt);
    } else if (lowercasePrompt.includes("websocket") || lowercasePrompt.includes("real-time") || lowercasePrompt.includes("chat")) {
        return generateWebSocketCode(serviceName, port, prompt);
    } else if (lowercasePrompt.includes("file") || lowercasePrompt.includes("upload") || lowercasePrompt.includes("download")) {
        return generateFileServiceCode(serviceName, port, prompt);
    } else if (lowercasePrompt.includes("auth") || lowercasePrompt.includes("login") || lowercasePrompt.includes("jwt")) {
        return generateAuthServiceCode(serviceName, port, prompt);
    } else {
        return generateCustomServiceCode(serviceName, port, prompt);
    }
}

function generateRestApiCode(string serviceName, string entity, string port, string prompt) returns string {
    return "import ballerina/http;\n\n# " + serviceName + " - Generated from: \"" + prompt + "\"\nlistener http:Listener httpListener = new (" + port + ");\n\n# Data storage (in-memory for demo)\nmap<json> " + entity + "Store = {};\nint nextId = 1;\n\nservice /api on httpListener {\n    \n    # Get all " + entity + "s\n    resource function get " + entity + "s() returns json {\n        return {\"message\": \"Retrieved all " + entity + "s\", \"data\": " + entity + "Store.toArray(), \"count\": " + entity + "Store.length()};\n    }\n    \n    # Get " + entity + " by ID\n    resource function get " + entity + "s/[string id]() returns json|http:NotFound {\n        if (" + entity + "Store.hasKey(id)) {\n            return {\"message\": \"" + entity + " found\", \"data\": " + entity + "Store.get(id)};\n        }\n        return <http:NotFound>{body: {\"error\": \"" + entity + " not found\", \"id\": id}};\n    }\n    \n    # Create new " + entity + "\n    resource function post " + entity + "s(json payload) returns json|http:BadRequest {\n        if (payload.name is ()) {\n            return <http:BadRequest>{body: {\"error\": \"Name is required\"}};\n        }\n        \n        string id = nextId.toString();\n        nextId += 1;\n        \n        json newItem = {\n            \"id\": id,\n            \"name\": payload.name,\n            \"createdAt\": \"2025-07-24T10:00:00Z\",\n            ...payload\n        };\n        \n        " + entity + "Store[id] = newItem;\n        return {\"message\": \"" + entity + " created successfully\", \"data\": newItem};\n    }\n    \n    # Update " + entity + "\n    resource function put " + entity + "s/[string id](json payload) returns json|http:NotFound {\n        if (!" + entity + "Store.hasKey(id)) {\n            return <http:NotFound>{body: {\"error\": \"" + entity + " not found\", \"id\": id}};\n        }\n        \n        json existing = " + entity + "Store.get(id);\n        json updated = {...existing, ...payload, \"updatedAt\": \"2025-07-24T10:00:00Z\"};\n        " + entity + "Store[id] = updated;\n        \n        return {\"message\": \"" + entity + " updated successfully\", \"data\": updated};\n    }\n    \n    # Delete " + entity + "\n    resource function delete " + entity + "s/[string id]() returns json|http:NotFound {\n        if (!" + entity + "Store.hasKey(id)) {\n            return <http:NotFound>{body: {\"error\": \"" + entity + " not found\", \"id\": id}};\n        }\n        \n        _ = " + entity + "Store.remove(id);\n        return {\"message\": \"" + entity + " deleted successfully\", \"id\": id};\n    }\n}";
}

function generateDatabaseCode(string serviceName, string entity, string port, string prompt) returns string {
    return "import ballerina/http;\nimport ballerina/sql;\nimport ballerinax/mysql;\n\n# " + serviceName + " with Database - Generated from: \"" + prompt + "\"\nconfigurable string DB_HOST = \"localhost\";\nconfigurable string DB_USER = \"root\";\nconfigurable string DB_PASSWORD = \"\";\nconfigurable string DB_NAME = \"" + entity + "_db\";\nconfigurable int DB_PORT = 3306;\n\nlistener http:Listener httpListener = new (" + port + ");\nmysql:Client dbClient = check new (DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT);\n\nservice /api on httpListener {\n    \n    # Get all " + entity + "s from database\n    resource function get " + entity + "s() returns json|error {\n        sql:ParameterizedQuery query = `SELECT * FROM " + entity + "s`;\n        stream<record {}, error?> resultStream = dbClient->query(query);\n        json[] items = [];\n        \n        check from record {} item in resultStream\n            do {\n                items.push(item.toJson());\n            };\n        \n        return {\"message\": \"Retrieved " + entity + "s from database\", \"data\": items, \"count\": items.length()};\n    }\n    \n    # Create new " + entity + "\n    resource function post " + entity + "s(json payload) returns json|error {\n        sql:ParameterizedQuery query = `INSERT INTO " + entity + "s (name, description) VALUES (${payload.name}, ${payload.description})`;\n        sql:ExecutionResult|sql:Error result = dbClient->execute(query);\n        \n        if result is sql:Error {\n            return {\"error\": \"Failed to create " + entity + "\", \"details\": result.message()};\n        }\n        \n        return {\"message\": \"" + entity + " created successfully\", \"id\": result.lastInsertId, \"affectedRows\": result.affectedRowCount};\n    }\n}";
}

function generateWebSocketCode(string serviceName, string port, string prompt) returns string {
    return "import ballerina/http;\nimport ballerina/websocket;\nimport ballerina/log;\n\n# " + serviceName + " WebSocket - Generated from: \"" + prompt + "\"\nlistener http:Listener httpListener = new (" + port + ");\n\n# Store connected clients\nwebsocket:Caller[] connectedClients = [];\n\nservice /ws on httpListener {\n    \n    resource function get .() returns websocket:Service {\n        return new " + serviceName + "();\n    }\n}\n\nservice class " + serviceName + " {\n    *websocket:Service;\n    \n    remote function onOpen(websocket:Caller caller) returns error? {\n        connectedClients.push(caller);\n        log:printInfo(\"New client connected. Total clients: \" + connectedClients.length().toString());\n        \n        # Send welcome message\n        check caller->writeTextMessage(\"Connected to " + serviceName + "!\");\n        \n        # Notify other clients\n        foreach var client in connectedClients {\n            if client !== caller {\n                var result = client->writeTextMessage(\"New user joined the session\");\n            }\n        }\n    }\n    \n    remote function onTextMessage(websocket:Caller caller, string text) returns error? {\n        log:printInfo(\"Received message: \" + text);\n        \n        # Broadcast message to all connected clients\n        foreach var client in connectedClients {\n            if client !== caller {\n                var result = client->writeTextMessage(\"User: \" + text);\n            }\n        }\n        \n        # Echo back to sender with confirmation\n        check caller->writeTextMessage(\"Message sent: \" + text);\n    }\n    \n    remote function onClose(websocket:Caller caller, int statusCode, string reason) {\n        # Remove client from connected list\n        int index = 0;\n        foreach var client in connectedClients {\n            if client === caller {\n                _ = connectedClients.remove(index);\n                break;\n            }\n            index += 1;\n        }\n        \n        log:printInfo(\"Client disconnected. Remaining clients: \" + connectedClients.length().toString());\n    }\n}";
}

function generateFileServiceCode(string serviceName, string port, string prompt) returns string {
    return "import ballerina/http;\nimport ballerina/io;\nimport ballerina/mime;\nimport ballerina/file;\nimport ballerina/time;\n\n# " + serviceName + " File Operations - Generated from: \"" + prompt + "\"\nlistener http:Listener httpListener = new (" + port + ");\n\n# Configure upload directory\nconst string UPLOAD_DIR = \"./uploads/\";\n\nservice /files on httpListener {\n    \n    # Upload file\n    resource function post upload(http:Request request) returns json|http:BadRequest|http:InternalServerError {\n        do {\n            # Ensure upload directory exists\n            if !check file:exists(UPLOAD_DIR) {\n                check file:createDir(UPLOAD_DIR, file:RECURSIVE);\n            }\n            \n            var bodyParts = request.getBodyParts();\n            \n            if bodyParts is mime:Entity[] {\n                json[] uploadedFiles = [];\n                \n                foreach var part in bodyParts {\n                    var mediaType = mime:getMediaType(part.getContentType());\n                    if mediaType is mime:MediaType {\n                        var byteStream = part.getByteStream();\n                        if byteStream is stream<byte[], io:Error?> {\n                            \n                            # Generate unique filename with timestamp\n                            string timestamp = time:utcNow()[0].toString();\n                            string fileName = \"file_\" + timestamp + \".txt\";\n                            string filePath = UPLOAD_DIR + fileName;\n                            \n                            # Write file\n                            check io:fileWriteBlocksFromStream(filePath, byteStream);\n                            \n                            uploadedFiles.push({\n                                \"fileName\": fileName,\n                                \"filePath\": filePath,\n                                \"uploadTime\": timestamp,\n                                \"status\": \"success\"\n                            });\n                        }\n                    }\n                }\n                \n                return {\n                    \"message\": \"Files uploaded successfully\",\n                    \"filesUploaded\": uploadedFiles.length(),\n                    \"files\": uploadedFiles\n                };\n            }\n            \n            return <http:BadRequest>{body: {\"error\": \"No files found in request\"}};\n            \n        } on fail var e {\n            return <http:InternalServerError>{body: {\"error\": \"File upload failed\", \"details\": e.message()}};\n        }\n    }\n    \n    # Download file by name\n    resource function get download/[string fileName]() returns http:Response|http:NotFound|http:InternalServerError {\n        do {\n            string filePath = UPLOAD_DIR + fileName;\n            \n            if !check file:exists(filePath) {\n                return <http:NotFound>{body: {\"error\": \"File not found\", \"fileName\": fileName}};\n            }\n            \n            byte[] fileContent = check io:fileReadBytes(filePath);\n            \n            http:Response response = new;\n            response.setBinaryPayload(fileContent);\n            response.setHeader(\"Content-Disposition\", \"attachment; filename=\" + fileName);\n            response.setHeader(\"Content-Length\", fileContent.length().toString());\n            \n            return response;\n            \n        } on fail var e {\n            return <http:InternalServerError>{body: {\"error\": \"File download failed\", \"details\": e.message()}};\n        }\n    }\n}";
}

function generateAuthServiceCode(string serviceName, string port, string prompt) returns string {
    return "import ballerina/http;\nimport ballerina/time;\nimport ballerina/log;\n\n# " + serviceName + " Authentication - Generated from: \"" + prompt + "\"\nlistener http:Listener httpListener = new (" + port + ");\n\n# In-memory user store (replace with database in production)\nmap<json> users = {\n    \"admin\": {\n        \"id\": \"1\",\n        \"username\": \"admin\",\n        \"password\": \"admin123\", # Should be hashed in production\n        \"email\": \"admin@example.com\",\n        \"role\": \"admin\"\n    },\n    \"user\": {\n        \"id\": \"2\", \n        \"username\": \"user\",\n        \"password\": \"user123\",\n        \"email\": \"user@example.com\",\n        \"role\": \"user\"\n    }\n};\n\nservice /auth on httpListener {\n    \n    # User login endpoint\n    resource function post login(json credentials) returns json|http:Unauthorized|http:BadRequest {\n        if credentials.username is () || credentials.password is () {\n            return <http:BadRequest>{body: {\"error\": \"Username and password are required\"}};\n        }\n        \n        string username = credentials.username.toString();\n        string password = credentials.password.toString();\n        \n        if !users.hasKey(username) {\n            return <http:Unauthorized>{body: {\"error\": \"Invalid credentials\"}};\n        }\n        \n        json user = users.get(username);\n        if user.password.toString() != password {\n            return <http:Unauthorized>{body: {\"error\": \"Invalid credentials\"}};\n        }\n        \n        # Generate simple token (in production, use JWT)\n        string token = \"token_\" + username + \"_\" + time:utcNow()[0].toString();\n        \n        return {\n            \"message\": \"Login successful\",\n            \"token\": token,\n            \"user\": {\n                \"id\": user.id,\n                \"username\": user.username,\n                \"email\": user.email,\n                \"role\": user.role\n            }\n        };\n    }\n    \n    # User registration endpoint\n    resource function post register(json userData) returns json|http:BadRequest|http:Conflict {\n        if userData.username is () || userData.password is () || userData.email is () {\n            return <http:BadRequest>{body: {\"error\": \"Username, password, and email are required\"}};\n        }\n        \n        string username = userData.username.toString();\n        \n        if users.hasKey(username) {\n            return <http:Conflict>{body: {\"error\": \"Username already exists\"}};\n        }\n        \n        json newUser = {\n            \"id\": (users.length() + 1).toString(),\n            \"username\": username,\n            \"password\": userData.password.toString(), # Should be hashed in production\n            \"email\": userData.email.toString(),\n            \"role\": \"user\",\n            \"createdAt\": time:utcNow()[0].toString()\n        };\n        \n        users[username] = newUser;\n        \n        return {\n            \"message\": \"User registered successfully\",\n            \"user\": {\n                \"id\": newUser.id,\n                \"username\": newUser.username,\n                \"email\": newUser.email,\n                \"role\": newUser.role\n            }\n        };\n    }\n}";
}

function generateCustomServiceCode(string serviceName, string port, string prompt) returns string {
    return "import ballerina/http;\nimport ballerina/log;\n\n# " + serviceName + " - Custom Generated Service\n# Generated from prompt: \"" + prompt + "\"\nlistener http:Listener httpListener = new (" + port + ");\n\nservice /api on httpListener {\n    \n    # Main endpoint based on your prompt\n    resource function get .() returns json {\n        return {\n            \"message\": \"Welcome to " + serviceName + "!\",\n            \"description\": \"This service was generated from your prompt\",\n            \"prompt\": \"" + prompt + "\",\n            \"timestamp\": \"2025-07-24T10:00:00Z\"\n        };\n    }\n    \n    # Process data based on your requirements\n    resource function post process(json data) returns json {\n        log:printInfo(\"Processing data: \" + data.toString());\n        \n        return {\n            \"status\": \"processed\",\n            \"service\": \"" + serviceName + "\",\n            \"originalPrompt\": \"" + prompt + "\",\n            \"inputData\": data,\n            \"processedAt\": \"2025-07-24T10:00:00Z\",\n            \"result\": \"Successfully processed your request\"\n        };\n    }\n    \n    # Custom business logic endpoint\n    resource function post execute(json payload) returns json {\n        return {\n            \"message\": \"Custom logic executed\",\n            \"service\": \"" + serviceName + "\", \n            \"executedAt\": \"2025-07-24T10:00:00Z\",\n            \"payload\": payload,\n            \"result\": {\n                \"success\": true,\n                \"description\": \"Your custom requirements have been processed\",\n                \"promptBased\": \"" + prompt + "\"\n            }\n        };\n    }\n}";
}

// Helper functions to extract information from prompts
function extractServiceName(string prompt) returns string {
    string lowercasePrompt = prompt.toLowerAscii();
    
    if (lowercasePrompt.includes("user")) {
        return "UserService";
    } else if (lowercasePrompt.includes("product")) {
        return "ProductService";
    } else if (lowercasePrompt.includes("order")) {
        return "OrderService";
    } else if (lowercasePrompt.includes("inventory")) {
        return "InventoryService";
    } else if (lowercasePrompt.includes("auth")) {
        return "AuthService";
    } else if (lowercasePrompt.includes("file")) {
        return "FileService";
    } else if (lowercasePrompt.includes("chat")) {
        return "ChatService";
    } else {
        return "CustomService";
    }
}

function extractEntities(string prompt) returns string[] {
    string[] entities = [];
    string lowercasePrompt = prompt.toLowerAscii();
    
    if (lowercasePrompt.includes("user")) {
        entities.push("user");
    }
    if (lowercasePrompt.includes("product")) {
        entities.push("product");
    }
    if (lowercasePrompt.includes("order")) {
        entities.push("order");
    }
    if (lowercasePrompt.includes("inventory")) {
        entities.push("inventory");
    }
    if (lowercasePrompt.includes("book")) {
        entities.push("book");
    }
    if (lowercasePrompt.includes("customer")) {
        entities.push("customer");
    }
    
    if (entities.length() == 0) {
        entities.push("item");
    }
    
    return entities;
}

function extractPort(string prompt) returns string {
    if (prompt.includes("8080")) {
        return "8080";
    } else if (prompt.includes("3000")) {
        return "3000";
    } else if (prompt.includes("8000")) {
        return "8000";
    } else {
        return "9090";
    }
}

function generateFlowchartData(string code, string prompt) returns json {
    string lowercasePrompt = prompt.toLowerAscii();
    string serviceName = extractServiceName(prompt);
    string[] entities = extractEntities(prompt);
    string primaryEntity = entities[0];
    
    if (lowercasePrompt.includes("rest api") || lowercasePrompt.includes("http service") || lowercasePrompt.includes("crud")) {
        return generateRestApiFlowchart(serviceName, primaryEntity, prompt);
    } else if (lowercasePrompt.includes("database") || lowercasePrompt.includes("mysql") || lowercasePrompt.includes("sql")) {
        return generateDatabaseFlowchart(serviceName, primaryEntity, prompt);
    } else if (lowercasePrompt.includes("websocket") || lowercasePrompt.includes("real-time") || lowercasePrompt.includes("chat")) {
        return generateWebSocketFlowchart(serviceName, prompt);
    } else if (lowercasePrompt.includes("file") || lowercasePrompt.includes("upload") || lowercasePrompt.includes("download")) {
        return generateFileServiceFlowchart(serviceName, prompt);
    } else if (lowercasePrompt.includes("auth") || lowercasePrompt.includes("login") || lowercasePrompt.includes("jwt")) {
        return generateAuthFlowchart(serviceName, prompt);
    } else if (lowercasePrompt.includes("microservice") || lowercasePrompt.includes("service")) {
        return generateGenericFlowchart(serviceName, primaryEntity, prompt);
    } else {
        return generateCustomFlowchart(serviceName, prompt);
    }
}

function generateRestApiFlowchart(string serviceName, string entity, string prompt) returns json {
    return {
        "mermaidDiagram": "graph TD\n    A[Client Request] --> B{HTTP Method}\n    B -->|GET /api/" + entity + "s| C[Get All " + entity + "s]\n    B -->|GET /api/" + entity + "s/id| D[Get " + entity + " by ID]\n    B -->|POST /api/" + entity + "s| E[Create New " + entity + "]\n    B -->|PUT /api/" + entity + "s/id| F[Update " + entity + "]\n    B -->|DELETE /api/" + entity + "s/id| G[Delete " + entity + "]\n    \n    C --> H[" + entity + "Store Map]\n    D --> H\n    E --> I[Validate Input]\n    I --> J[Generate ID]\n    J --> H\n    F --> K[Check if Exists]\n    K --> H\n    G --> L[Remove from Store]\n    \n    H --> M[Return JSON Response]\n    L --> M\n    \n    style A fill:#e1f5fe\n    style M fill:#e8f5e8\n    style H fill:#fff3e0\n    style I fill:#fce4ec",
        "type": "REST API Service",
        "prompt": prompt,
        "components": [
            "HTTP Listener (Port 9090)",
            serviceName,
            "In-memory " + entity + " Store",
            "CRUD Operations",
            "JSON Responses"
        ]
    };
}

function generateDatabaseFlowchart(string serviceName, string entity, string prompt) returns json {
    return {
        "mermaidDiagram": "graph TD\n    A[Client Request] --> B[HTTP Service]\n    B --> C{Operation Type}\n    \n    C -->|SELECT| D[Query Database]\n    C -->|INSERT| E[Insert Record]\n    C -->|UPDATE| F[Update Record] \n    C -->|DELETE| G[Delete Record]\n    \n    D --> H[(MySQL Database)]\n    E --> H\n    F --> H\n    G --> H\n    \n    H --> I[SQL Result]\n    I --> J[Process Data]\n    J --> K[Return JSON]\n    \n    L[Database Config] --> H\n    M[Connection Pool] --> H\n    \n    style A fill:#e1f5fe\n    style H fill:#e3f2fd\n    style K fill:#e8f5e8\n    style L fill:#fff3e0",
        "type": "Database Service",
        "prompt": prompt,
        "components": [
            "HTTP Listener",
            serviceName,
            "MySQL Database Connection",
            "SQL Operations",
            "Error Handling",
            "JSON Responses"
        ]
    };
}

function generateWebSocketFlowchart(string serviceName, string prompt) returns json {
    return {
        "mermaidDiagram": "graph TD\n    A[Client Connection] --> B[WebSocket Handshake]\n    B --> C[" + serviceName + "]\n    C --> D[onOpen Event]\n    D --> E[Add to Connected Clients]\n    E --> F[Send Welcome Message]\n    \n    G[Message Received] --> H[onTextMessage Event]\n    H --> I[Broadcast to All Clients]\n    I --> J[Send Confirmation]\n    \n    K[Client Disconnect] --> L[onClose Event]\n    L --> M[Remove from Connected Clients]\n    M --> N[Notify Other Clients]\n    \n    O[Error Occurred] --> P[onError Event]\n    P --> Q[Log Error]\n    \n    style A fill:#e1f5fe\n    style C fill:#f3e5f5\n    style E fill:#fff3e0\n    style I fill:#e8f5e8",
        "type": "WebSocket Service",
        "prompt": prompt,
        "components": [
            "WebSocket Listener",
            serviceName,
            "Client Management",
            "Real-time Messaging",
            "Event Handlers",
            "Broadcasting"
        ]
    };
}

function generateFileServiceFlowchart(string serviceName, string prompt) returns json {
    return {
        "mermaidDiagram": "graph TD\n    A[File Operation Request] --> B{Operation Type}\n    \n    B -->|POST /upload| C[File Upload]\n    B -->|GET /download| D[File Download]\n    B -->|GET /list| E[List Files]\n    B -->|DELETE /remove| F[Delete File]\n    \n    C --> G[Process MultiPart]\n    G --> H[Generate Unique Name]\n    H --> I[Save to Upload Directory]\n    I --> J[Return Upload Info]\n    \n    D --> K[Check File Exists]\n    K --> L[Read File Content]\n    L --> M[Set Download Headers]\n    M --> N[Return File]\n    \n    E --> O[Read Directory]\n    O --> P[Get File Metadata]\n    P --> Q[Return File List]\n    \n    F --> R[Verify File Exists]\n    R --> S[Delete from Filesystem]\n    S --> T[Return Success]\n    \n    style A fill:#e1f5fe\n    style I fill:#e8f5e8\n    style L fill:#fff3e0\n    style S fill:#ffebee",
        "type": "File Service", 
        "prompt": prompt,
        "components": [
            "HTTP Listener",
            serviceName,
            "File System Operations",
            "Upload Directory Management",
            "MultiPart Processing",
            "File Metadata"
        ]
    };
}

function generateAuthFlowchart(string serviceName, string prompt) returns json {
    return {
        "mermaidDiagram": "graph TD\n    A[Authentication Request] --> B{Request Type}\n    \n    B -->|POST /login| C[Login Process]\n    B -->|POST /register| D[Registration Process]\n    B -->|POST /verify| E[Token Verification]\n    B -->|GET /profile| F[Get User Profile]\n    \n    C --> G[Validate Credentials]\n    G --> H{Valid User?}\n    H -->|Yes| I[Generate JWT Token]\n    H -->|No| J[Return Unauthorized]\n    I --> K[Return Token & User Info]\n    \n    D --> L[Check Username Exists]\n    L --> M{Available?}\n    M -->|Yes| N[Create New User]\n    M -->|No| O[Return Conflict]\n    N --> P[Return Success]\n    \n    E --> Q[Parse Authorization Header]\n    Q --> R[Validate JWT Token]\n    R --> S{Valid Token?}\n    S -->|Yes| T[Return User Info]\n    S -->|No| U[Return Unauthorized]\n    \n    F --> V[Extract Token]\n    V --> W[Validate & Get User]\n    W --> X[Return Profile]\n    \n    style A fill:#e1f5fe\n    style I fill:#e8f5e8\n    style R fill:#fff3e0\n    style J fill:#ffebee\n    style U fill:#ffebee",
        "type": "Authentication Service",
        "prompt": prompt,
        "components": [
            "HTTP Listener",
            serviceName,
            "JWT Token Management",
            "User Store",
            "Credential Validation",
            "Protected Endpoints"
        ]
    };
}

function generateGenericFlowchart(string serviceName, string entity, string prompt) returns json {
    return {
        "mermaidDiagram": "graph TD\n    A[Client Request] --> B[" + serviceName + "]\n    B --> C{Endpoint}\n    \n    C -->|/health| D[Health Check]\n    C -->|/info| E[Service Info]\n    C -->|/" + entity + "| F[Business Logic]\n    C -->|/" + entity + "/batch| G[Batch Processing]\n    C -->|/" + entity + "/search| H[Search Query]\n    \n    D --> I[Return Service Status]\n    E --> J[Return Service Details]\n    F --> K[Process " + entity + " Data]\n    G --> L[Process Multiple Items]\n    H --> M[Execute Search]\n    \n    K --> N[Log Processing]\n    L --> O[Batch Results]\n    M --> P[Search Results]\n    \n    N --> Q[Return Response]\n    O --> Q\n    P --> Q\n    I --> Q\n    J --> Q\n    \n    style A fill:#e1f5fe\n    style B fill:#f3e5f5\n    style Q fill:#e8f5e8\n    style K fill:#fff3e0",
        "type": "Generic Service",
        "prompt": prompt,
        "components": [
            "HTTP Listener",
            serviceName,
            "Health Monitoring", 
            "Business Logic Processing",
            "Batch Operations",
            "Search Functionality"
        ]
    };
}

function generateCustomFlowchart(string serviceName, string prompt) returns json {
    return {
        "mermaidDiagram": "graph TD\n    A[Custom Request] --> B[" + serviceName + "]\n    B --> C{Endpoint}\n    \n    C -->|GET /| D[Welcome Endpoint]\n    C -->|POST /process| E[Process Data]\n    C -->|POST /execute| F[Execute Custom Logic]\n    \n    D --> G[Return Service Info]\n    E --> H[Log Input Data]\n    F --> I[Apply Business Rules]\n    \n    H --> J[Process Request]\n    I --> K[Generate Result]\n    \n    J --> L[Return Processed Data]\n    K --> M[Return Custom Response]\n    G --> N[Service Response]\n    \n    style A fill:#e1f5fe\n    style B fill:#f3e5f5\n    style L fill:#e8f5e8\n    style M fill:#e8f5e8\n    style N fill:#e8f5e8",
        "type": "Custom Service",
        "prompt": prompt,
        "components": [
            "HTTP Listener",
            serviceName,
            "Custom Business Logic",
            "Data Processing",
            "Flexible Endpoints",
            "Prompt-Based Generation"
        ]
    };
}
