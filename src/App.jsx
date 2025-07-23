import { useState } from 'react'
import ChatInterface from './components/ChatInterface'
import './App.css'

function App() {
  return (
    <div className="App">
      <header className="app-header">
        <div className="app-header-content">
          <h1>Flowerina.ai</h1>
          <p>Generate Ballerina code with AI assistance</p>
        </div>
      </header>
      <main className="chat-main">
        <ChatInterface />
      </main>
    </div>
  )
}

export default App
