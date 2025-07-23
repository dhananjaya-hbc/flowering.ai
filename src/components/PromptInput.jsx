import { useState } from 'react'
import { Play, Wand2, FileCode } from 'lucide-react'
import './PromptInput.css'

const PromptInput = ({ 
  prompt, 
  onPromptChange, 
  onGenerate, 
  isLoading, 
  templates, 
  onTemplateSelect 
}) => {
  const [showTemplates, setShowTemplates] = useState(false)

  const handleSubmit = (e) => {
    e.preventDefault()
    onGenerate()
  }

  return (
    <div className="prompt-input">
      <div className="input-header">
        <h2>
          <Wand2 size={24} />
          Describe Your Ballerina Service
        </h2>
        <p>Enter a description of what you want to build, and we'll generate the Ballerina code for you!</p>
      </div>

      <form onSubmit={handleSubmit} className="prompt-form">
        <div className="textarea-container">
          <textarea
            value={prompt}
            onChange={(e) => onPromptChange(e.target.value)}
            placeholder="e.g., Create a REST API service with user authentication and CRUD operations for a blog platform..."
            rows={4}
            className="prompt-textarea"
            disabled={isLoading}
          />
        </div>

        <div className="form-actions">
          <button
            type="button"
            onClick={() => setShowTemplates(!showTemplates)}
            className="template-btn"
            disabled={isLoading}
          >
            <FileCode size={16} />
            Templates
          </button>
          
          <button
            type="submit"
            className="generate-btn"
            disabled={isLoading || !prompt.trim()}
          >
            {isLoading ? (
              <>
                <div className="loading-spinner" />
                Generating...
              </>
            ) : (
              <>
                <Play size={16} />
                Generate Code
              </>
            )}
          </button>
        </div>
      </form>

      {showTemplates && templates.length > 0 && (
        <div className="templates-section">
          <h3>Quick Start Templates</h3>
          <div className="templates-grid">
            {templates.map((template) => (
              <div
                key={template.id}
                className="template-card"
                onClick={() => {
                  onTemplateSelect(template)
                  setShowTemplates(false)
                }}
              >
                <h4>{template.name}</h4>
                <p>{template.description}</p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

export default PromptInput
