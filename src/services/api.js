import axios from 'axios'

const API_BASE_URL = 'http://localhost:8081/api'

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 seconds timeout
})

// Request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log('API Request:', config.method?.toUpperCase(), config.url, config.data)
    return config
  },
  (error) => {
    console.error('API Request Error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    console.log('API Response:', response.status, response.data)
    return response
  },
  (error) => {
    console.error('API Response Error:', error.response?.data || error.message)
    
    if (error.code === 'ECONNREFUSED') {
      throw new Error('Cannot connect to the Ballerina backend service. Please make sure it\'s running on port 8081.')
    }
    
    if (error.response) {
      throw new Error(error.response.data?.error || `Server error: ${error.response.status}`)
    }
    
    throw new Error(error.message || 'An unexpected error occurred')
  }
)

export const generateCode = async (prompt) => {
  try {
    const response = await api.post('/generate-code', { prompt })
    return response.data
  } catch (error) {
    console.error('Generate code error:', error)
    throw error
  }
}

export const getTemplates = async () => {
  try {
    const response = await api.get('/templates')
    return response.data
  } catch (error) {
    console.error('Get templates error:', error)
    throw error
  }
}

export const healthCheck = async () => {
  try {
    const response = await api.get('/health')
    return response.data
  } catch (error) {
    console.error('Health check error:', error)
    throw error
  }
}

export default api
