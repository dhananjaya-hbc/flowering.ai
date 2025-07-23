import { useState, useRef, useEffect } from 'react'
import { generateCode } from '../services/api'
import CodeEditor from './CodeEditor'
import FlowchartDisplay from './FlowchartDisplay'
import './ChatInterface.css'

const ChatInterface = () => {
  const [messages, setMessages] = useState([
    {
      id: 1,
      type: 'assistant',
      content: 'Hello! I\'m Flowerina, your AI assistant for generating Ballerina code. What would you like me to help you build today?',
      timestamp: new Date()
    }
  ])
  const [inputValue, setInputValue] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const messagesEndRef = useRef(null)
  const textareaRef = useRef(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!inputValue.trim() || isLoading) return

    const userMessage = {
      id: Date.now(),
      type: 'user',
      content: inputValue.trim(),
      timestamp: new Date()
    }

    setMessages(prev => [...prev, userMessage])
    setInputValue('')
    setIsLoading(true)

    try {
      const result = await generateCode(inputValue.trim())
      console.log('API result:', result)
      console.log('Flowchart data:', result.flowchart)
      console.log('Mermaid diagram:', result.flowchart?.mermaidDiagram)
      
      const assistantMessage = {
        id: Date.now() + 1,
        type: 'assistant',
        content: 'I\'ve generated the Ballerina code for your request. Here\'s what I created:',
        code: result.code,
        flowchart: result.flowchart,
        timestamp: new Date()
      }

      setMessages(prev => [...prev, assistantMessage])
    } catch (error) {
      const errorMessage = {
        id: Date.now() + 1,
        type: 'assistant',
        content: `I apologize, but I encountered an error while generating the code: ${error.message}`,
        isError: true,
        timestamp: new Date()
      }
      setMessages(prev => [...prev, errorMessage])
    } finally {
      setIsLoading(false)
    }
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSubmit(e)
    }
  }

  const formatTime = (date) => {
    return new Intl.DateTimeFormat('en-US', {
      hour: '2-digit',
      minute: '2-digit'
    }).format(date)
  }

  return (
    <div className="chat-interface">
      <div className="chat-messages">
        {messages.map((message) => (
          <div key={message.id} className={`message ${message.type}`}>
            <div className="message-avatar">
              {message.type === 'user' ? 'You' : 'F'}
            </div>
            <div className="message-content">
              <div className="message-header">
                <span className="message-author">
                  {message.type === 'user' ? 'You' : 'Flowerina'}
                </span>
                <span className="message-time">
                  {formatTime(message.timestamp)}
                </span>
              </div>
              <div className={`message-text ${message.isError ? 'error' : ''}`}>
                {message.content}
              </div>
              {message.code && (
                <div className="message-code">
                  <div className="code-section">
                    <h4>Generated Code:</h4>
                    <CodeEditor code={message.code} language="ballerina" readOnly />
                  </div>
                  {message.flowchart && (
                    <div className="flowchart-section">
                      <h4>Architecture Diagram:</h4>
                      <FlowchartDisplay data={message.flowchart} />
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="message assistant loading">
            <div className="message-avatar">F</div>
            <div className="message-content">
              <div className="message-header">
                <span className="message-author">Flowerina</span>
                <span className="message-time">now</span>
              </div>
              <div className="message-text">
                <div className="typing-indicator">
                  <div className="typing-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                  </div>
                  Generating your Ballerina code...
                </div>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>
      
      <div className="chat-input-container">
        <form onSubmit={handleSubmit} className="chat-form">
          <div className="input-wrapper">
            <textarea
              ref={textareaRef}
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Describe the Ballerina code you want me to generate..."
              className="chat-textarea"
              rows="1"
              disabled={isLoading}
            />
            <button
              type="submit"
              disabled={!inputValue.trim() || isLoading}
              className="send-button"
            >
              {isLoading ? '⏳' : '↑'}
            </button>
          </div>
        </form>
        <div className="input-hints">
          <span>Press Enter to send, Shift+Enter for new line</span>
        </div>
      </div>
    </div>
  )
}

export default ChatInterface
