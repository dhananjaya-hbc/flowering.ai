import { useState, useEffect, useRef } from 'react'
import mermaid from 'mermaid'
import './FlowchartDisplay.css'

const FlowchartDisplay = ({ data }) => {
  const mermaidRef = useRef(null)
  
  // Initialize Mermaid
  useEffect(() => {
    mermaid.initialize({
      startOnLoad: false, // Set to false to manually control rendering
      theme: 'dark',
      flowchart: {
        useMaxWidth: true,
        htmlLabels: true
      },
      themeVariables: {
        primaryColor: '#19c37d',
        primaryTextColor: '#ececf1',
        primaryBorderColor: '#4d4d4f',
        lineColor: '#565869',
        sectionBkgColor: '#2f2f2f',
        altSectionBkgColor: '#3c3c3c',
        gridColor: '#4d4d4f',
        secondaryColor: '#10a37f',
        tertiaryColor: '#212121',
        background: '#212121',
        mainBkg: '#2f2f2f',
        secondBkg: '#3c3c3c',
        tertiaryBkg: '#212121'
      }
    })
    
    // Test rendering with a simple diagram
    if (mermaidRef.current && !data?.mermaidDiagram) {
      const testDiagram = `graph TD
        A[Test] --> B[Working]
        B --> C[Success]`
      
      const renderTest = async () => {
        try {
          const { svg } = await mermaid.render('test-diagram', testDiagram)
          mermaidRef.current.innerHTML = svg
        } catch (error) {
          console.error('Test render failed:', error)
        }
      }
      renderTest()
    }
  }, [])

  // Render Mermaid diagram
  useEffect(() => {
    console.log('FlowchartDisplay data:', data)
    console.log('Mermaid diagram string:', data?.mermaidDiagram)
    
    if (data?.mermaidDiagram && mermaidRef.current) {
      const renderMermaid = async () => {
        try {
          console.log('Starting Mermaid render...')
          mermaidRef.current.innerHTML = 'Rendering...'
          
          // Clean up any previous content
          mermaidRef.current.innerHTML = ''
          
          // Generate unique ID for each render
          const diagramId = `mermaid-${Date.now()}`
          
          const { svg } = await mermaid.render(diagramId, data.mermaidDiagram)
          console.log('Mermaid SVG generated successfully')
          
          if (svg) {
            mermaidRef.current.innerHTML = svg
          } else {
            throw new Error('No SVG generated')
          }
        } catch (error) {
          console.error('Mermaid rendering error:', error)
          mermaidRef.current.innerHTML = `
            <div class="mermaid-error">
              <p>Error rendering diagram: ${error.message}</p>
              <details>
                <summary>View Mermaid Code</summary>
                <pre>${data.mermaidDiagram}</pre>
              </details>
            </div>
          `
        }
      }
      renderMermaid()
    } else {
      console.log('No mermaid data or ref:', { 
        hasMermaidDiagram: !!data?.mermaidDiagram, 
        hasRef: !!mermaidRef.current,
        data: data
      })
    }
  }, [data?.mermaidDiagram])

  if (!data) {
    return (
      <div className="no-flowchart">
        <div className="no-flowchart-icon">📊</div>
        <h3>No flowchart data available</h3>
        <p>Generate some Ballerina code to see the architecture diagram here!</p>
      </div>
    )
  }

  return (
    <div className="flowchart-display">
      <div className="flowchart-controls">
        {data.summary && (
          <div className="flowchart-summary">
            <span>Services: {data.summary.services}</span>
            <span>Resources: {data.summary.resources}</span>
            <span>Imports: {data.summary.imports}</span>
          </div>
        )}
      </div>

      {data.mermaidDiagram ? (
        <div className="mermaid-container">
          <div className="mermaid-visual" ref={mermaidRef}>
            {/* Mermaid diagram will be rendered here */}
          </div>
          <div className="mermaid-actions">
            <button
              onClick={() => navigator.clipboard.writeText(data.mermaidDiagram)}
              className="copy-btn"
            >
              📋 Copy Diagram Code
            </button>
            <button
              onClick={() => {
                const svg = mermaidRef.current?.querySelector('svg')
                if (svg) {
                  const svgData = new XMLSerializer().serializeToString(svg)
                  const blob = new Blob([svgData], { type: 'image/svg+xml' })
                  const url = URL.createObjectURL(blob)
                  const a = document.createElement('a')
                  a.href = url
                  a.download = 'flowchart.svg'
                  a.click()
                  URL.revokeObjectURL(url)
                }
              }}
              className="download-btn"
            >
              💾 Download SVG
            </button>
          </div>
        </div>
      ) : (
        <div className="no-mermaid-data">
          <p>No Mermaid diagram available for this code generation.</p>
          <pre>Data received: {JSON.stringify(data, null, 2)}</pre>
        </div>
      )}
    </div>
  )
}

export default FlowchartDisplay
