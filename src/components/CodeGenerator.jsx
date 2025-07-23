import { useState, useEffect } from 'react'
import CodeEditor from './CodeEditor'
import FlowchartDisplay from './FlowchartDisplay'
import PromptInput from './PromptInput'
import { generateCode, getTemplates } from '../services/api'
import './CodeGenerator.css'

const CodeGenerator = () => {
  const [prompt, setPrompt] = useState('')
  const [generatedCode, setGeneratedCode] = useState('')
  const [flowchartData, setFlowchartData] = useState(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState(null)
  const [templates, setTemplates] = useState([])

  useEffect(() => {
    // Load available templates on component mount
    const loadTemplates = async () => {
      try {
        const templatesData = await getTemplates()
        setTemplates(templatesData.templates || [])
      } catch (err) {
        console.error('Failed to load templates:', err)
      }
    }
    loadTemplates()
  }, [])

  const handleGenerate = async () => {
    if (!prompt.trim()) {
      setError('Please enter a prompt to generate code')
      return
    }

    setIsLoading(true)
    setError(null)

    try {
      const result = await generateCode(prompt)
      
      if (result.code && result.flowchart) {
        setGeneratedCode(result.code)
        setFlowchartData(result.flowchart)
      } else {
        setError(result.error || 'Failed to generate code')
      }
    } catch (err) {
      setError(err.message || 'An error occurred while generating code')
    } finally {
      setIsLoading(false)
    }
  }

  const handleTemplateSelect = (template) => {
    setPrompt(`Generate a ${template.name.toLowerCase()}: ${template.description}`)
  }

  const clearAll = () => {
    setPrompt('')
    setGeneratedCode('')
    setFlowchartData(null)
    setError(null)
  }

  return (
    <div className="code-generator">
      <div className="generator-container">
        {/* Input Section */}
        <div className="input-section">
          <PromptInput
            prompt={prompt}
            onPromptChange={setPrompt}
            onGenerate={handleGenerate}
            isLoading={isLoading}
            templates={templates}
            onTemplateSelect={handleTemplateSelect}
          />
          
          {error && (
            <div className="error-message">
              <strong>Error:</strong> {error}
            </div>
          )}
        </div>

        {/* Results Section */}
        {(generatedCode || flowchartData) && (
          <div className="results-section">
            <div className="results-header">
              <h2>Generated Results</h2>
              <button onClick={clearAll} className="clear-btn">
                Clear All
              </button>
            </div>

            <div className="results-content">
              {/* Code Display */}
              {generatedCode && (
                <div className="code-section">
                  <h3>Generated Ballerina Code</h3>
                  <CodeEditor code={generatedCode} readOnly={true} />
                </div>
              )}

              {/* Flowchart Display */}
              {flowchartData && (
                <div className="flowchart-section">
                  <h3>Service Architecture Flowchart</h3>
                  <FlowchartDisplay data={flowchartData} />
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default CodeGenerator
