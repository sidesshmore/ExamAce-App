import React, { useState, useRef, useEffect } from 'react';

const AIChatInterface = () => {
  // State to manage chat messages
  const [question, setQuestion] = useState('');
  const [messages, setMessages] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);

  // Function to scroll to the bottom of messages
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  // Scroll to bottom when messages change
  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // Mock function to simulate AI response
  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Trim the question and ignore if empty
    const trimmedQuestion = question.trim();
    if (!trimmedQuestion) return;

    // Add user message to chat history
    const userMessage = {
      id: Date.now(),
      type: 'user',
      content: trimmedQuestion
    };

    // Update messages with user question
    setMessages(prevMessages => [...prevMessages, userMessage]);
    
    // Reset input and set loading
    setQuestion('');
    setIsLoading(true);

    // Simulate API delay and response
    setTimeout(() => {
      // Array of mock responses
      const mockResponses = [
        "That's an interesting question! Let me think about it.",
        "AI is processing your query with advanced algorithms.",
        "Hmm, fascinating. Here's my perspective...",
        "Breaking down your question into key components...",
        "Analyzing the context and preparing a comprehensive response."
      ];

      // Select a random mock response
      const randomResponse = 
        mockResponses[Math.floor(Math.random() * mockResponses.length)];
      
      // Add AI response to chat history
      const aiMessage = {
        id: Date.now() + 1,
        type: 'ai',
        content: randomResponse
      };

      setMessages(prevMessages => [...prevMessages, aiMessage]);
      setIsLoading(false);
    }, 1500); // Simulate a 1.5-second delay
  };

  return (
    <div className="flex h-[90vh]">
      {/* Left Pane - Question Input */}
      <div className="w-screen p-2 border-r bg-gray-50">
        <div className="bg-white shadow-md rounded-lg h-full p-4">
          <h2 className="text-xl font-bold mb-4 text-gray-800">Ask ExamAce</h2>
          
          {/* Chat History */}
          <div className="h-[calc(100%-200px)] overflow-y-auto mb-4 space-y-2">
            {messages.map((message) => (
              <div 
                key={message.id} 
                className={`p-2 rounded-lg max-w-full 
                  ${message.type === 'user' 
                    ? 'bg-blue-100 text-blue-800 text-right' 
                    : 'bg-gray-100 text-gray-800 text-left'}`}
              >
                {message.content}
              </div>
            ))}
            {isLoading && (
              <div className="p-2 bg-gray-100 text-gray-800 rounded-lg flex items-center">
                <svg 
                  className="animate-spin h-5 w-5 text-blue-500 mr-2" 
                  xmlns="http://www.w3.org/2000/svg" 
                  fill="none" 
                  viewBox="0 0 24 24"
                >
                  <circle 
                    className="opacity-25" 
                    cx="12" 
                    cy="12" 
                    r="10" 
                    stroke="currentColor" 
                    strokeWidth="4"
                  ></circle>
                  <path 
                    className="opacity-75" 
                    fill="currentColor" 
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  ></path>
                </svg>
                AI is thinking...
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>
          
          {/* Input Area */}
          <form onSubmit={handleSubmit} className="flex flex-col">
            <textarea 
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              placeholder="Type your question here..."
              className="flex-grow resize-none mb-4 p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-black"
              required
            />
            <button 
              type="submit" 
              disabled={!question}
              className="bg-blue-500 text-white p-3 rounded-md hover:bg-blue-600 
                         transition duration-300 ease-in-out
                         disabled:bg-gray-300 disabled:cursor-not-allowed"
            >
              Submit Question
            </button>
          </form>
        </div>
      </div>

      {/* Right Pane - AI Response */}
      <div className="w-screen p-2 bg-gray-50">
        <div className="bg-white shadow-md rounded-lg h-full p-4">
          <h2 className="text-xl font-bold mb-4 text-gray-800">AI Response</h2>
          <div className="h-[calc(100%-50px)] border border-gray-300 rounded-md p-4 overflow-auto">
            {isLoading ? (
              <div className="flex items-center justify-center h-full">
                <svg 
                  className="animate-spin h-8 w-8 text-blue-500 mr-3" 
                  xmlns="http://www.w3.org/2000/svg" 
                  fill="none" 
                  viewBox="0 0 24 24"
                >
                  <circle 
                    className="opacity-25" 
                    cx="12" 
                    cy="12" 
                    r="10" 
                    stroke="currentColor" 
                    strokeWidth="4"
                  ></circle>
                  <path 
                    className="opacity-75" 
                    fill="currentColor" 
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  ></path>
                </svg>
                <span className="text-gray-600">AI is thinking...</span>
              </div>
            ) : (
              <p className={`${messages.length > 0 ? 'text-gray-800' : 'text-gray-400'}`}>
                {messages.length > 0 
                  ? messages[messages.length - 1].type === 'ai' 
                    ? messages[messages.length - 1].content 
                    : 'Your AI response will appear here'
                  : 'Your AI response will appear here'}
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default AIChatInterface;