import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, NavLink } from 'react-router-dom';
import { Home, MessageCircle, BookOpen, Menu, X } from 'lucide-react';
import AIChatInterface from './playground'
import BookBrowsingApp from './Subject'
// import SidebarApp from './Sidebar'

// Individual Page Components
const ChatWindow = () => (
  <div className="p-6 bg-gray-100 min-h-screen">
    <h1 className="text-2xl font-bold mb-4">Chat Window</h1>
    <p>This is the main chat interface area.</p>
  </div>
);

const SubjectSelection = () => (
  <div className="p-6 bg-gray-100 min-h-screen">
    <h1 className="text-2xl font-bold mb-4">Subject Selection</h1>
    <p>Choose your preferred subject or learning track.</p>
  </div>
);

const BCPage = () => (
  <div className="p-6 bg-gray-100 min-h-screen">
    <h1 className="text-2xl font-bold mb-4">BC Page</h1>
    <p>Additional content for the BC section.</p>
  </div>
);

// Main App Component with Sidebar
const SidebarApp = () => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  return (
    <Router>
      <div className="flex">
        {/* Hamburger Menu Button */}
        <button 
          onClick={toggleSidebar} 
          className="fixed top-4 left-4 z-50 bg-white p-2 rounded-md shadow-md hover:bg-gray-100 transition-colors "
        >
          {isSidebarOpen ? <X size={24} /> : <Menu size={24} />}
        </button>

        {/* Sidebar */}
        <div 
          className={`
            w-64 bg-white border-r h-screen fixed left-0 top-0 p-4 shadow-lg 
            transition-transform duration-300 ease-in-out
            ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}
          `}
        >
          <div className="mb-10 text-center">
            <h2 className="text-xl font-bold text-gray-800 pt-12">Navigation</h2>
          </div>
          
          <nav className="space-y-2">
            <NavLink 
              to="/" 
              className={({ isActive }) => `
                flex items-center p-3 rounded-lg transition-colors duration-200
                ${isActive 
                  ? 'bg-blue-100 text-blue-700' 
                  : 'hover:bg-gray-100 text-gray-700'}
              `}
            >
              <Home className="mr-3" size={20} />
              Chat Window
            </NavLink>
            
            <NavLink 
              to="/subjects" 
              className={({ isActive }) => `
                flex items-center p-3 rounded-lg transition-colors duration-200
                ${isActive 
                  ? 'bg-blue-100 text-blue-700' 
                  : 'hover:bg-gray-100 text-gray-700'}
              `}
            >
              <BookOpen className="mr-3" size={20} />
              Subject Selection
            </NavLink>
            
            <NavLink 
              to="/bc" 
              className={({ isActive }) => `
                flex items-center p-3 rounded-lg transition-colors duration-200
                ${isActive 
                  ? 'bg-blue-100 text-blue-700' 
                  : 'hover:bg-gray-100 text-gray-700'}
              `}
            >
              <MessageCircle className="mr-3" size={20} />
              BC
            </NavLink>
          </nav>
        </div>
        
        {/* Main Content Area */}
        <div className={`
          w-full transition-all duration-300 ease-in-out
          ${isSidebarOpen ? 'ml-64' : 'ml-0'}
        `}>
          <Routes>
            <Route path="/" element={<AIChatInterface />} />
            <Route path="/subjects" element={<BookBrowsingApp />} />
            {/* <Route path="/bc" element={<BCPage />} /> */}
          </Routes>
        </div>
      </div>
    </Router>
  );
};

export default SidebarApp;