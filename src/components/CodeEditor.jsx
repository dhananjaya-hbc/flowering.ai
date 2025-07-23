import { useState } from 'react'
import CodeMirror from '@uiw/react-codemirror'
import { oneDark } from '@codemirror/theme-one-dark'
import './CodeEditor.css'

const CodeEditor = ({ code, onChange, readOnly = false, language = 'ballerina', height = 'auto' }) => {
  const [copied, setCopied] = useState(false)

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(code)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (err) {
      console.error('Failed to copy code:', err)
    }
  }

  return (
    <div className="code-editor">
      {readOnly && (
        <div className="code-editor-header">
          <span className="code-editor-title">Generated Code</span>
          <button
            onClick={handleCopy}
            className={`copy-button ${copied ? 'copied' : ''}`}
          >
            {copied ? 'Copied!' : 'Copy'}
          </button>
        </div>
      )}
      <div className="editor-container">
        <CodeMirror
          value={code}
          onChange={onChange}
          theme={oneDark}
          editable={!readOnly}
          basicSetup={{
            lineNumbers: true,
            foldGutter: true,
            dropCursor: false,
            allowMultipleSelections: false,
            indentOnInput: true,
            bracketMatching: true,
            closeBrackets: true,
            autocompletion: true,
            highlightSelectionMatches: false
          }}
          height={height === 'auto' ? undefined : height}
          maxHeight="500px"
        />
      </div>
    </div>
  )
}

export default CodeEditor
