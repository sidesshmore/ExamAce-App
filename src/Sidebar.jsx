import React, { useState } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  NavLink,
} from "react-router-dom";
import { Home, BookOpen, MessageCircle, MoveLeft, X, Menu } from "lucide-react";
import AIChatInterface from "./playground";
import BookBrowsingApp from "./Subject.jsx";

// Login Modal Component
const LoginModal = ({ isOpen, onClose }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div className="bg-white p-8 rounded-lg shadow-lg w-96">
        <h2 className="text-2xl font-semibold mb-4">Login</h2>
        <form>
          <div className="mb-4">
            <label
              className="block text-gray-700 text-sm font-bold mb-2"
              htmlFor="username"
            >
              Email
            </label>
            <input
              className="appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
              id="Email"
              type="text"
              placeholder="Username"
            />
          </div>
          <div className="mb-6">
            <label
              className="block text-gray-700 text-sm font-bold mb-2"
              htmlFor="password"
            >
              Password
            </label>
            <input
              className="appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline"
              id="password"
              type="password"
              placeholder="Password"
            />
          </div>
          <div className="flex items-center justify-between">
            <button
              to="/"
              className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
              type="button"
            >
              Sign In
            </button>
            <button
              className="inline-block align-baseline font-bold text-sm text-blue-500 hover:text-blue-800"
              onClick={onClose}
            >
              Close
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

const SidebarApp = () => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  const LogIn = () => {
    setIsLoginModalOpen(true);
  };

  const closeLoginModal = () => {
    setIsLoginModalOpen(false);
  };

  return (
    <Router>
      <div className="flex relative min-h-screen">
        <button
          onClick={toggleSidebar}
          className="fixed top-4 left-4 z-50 bg-white p-2 rounded-md shadow-md hover:bg-gray-100 transition-colors"
        >
          {isSidebarOpen ? <X size={12} /> : <Menu size={14} />}
        </button>

        <div
          className={`w-64 bg-white border-r h-screen fixed left-0 top-0 p-4 shadow-lg transition-transform duration-300 ease-in-out ${
            isSidebarOpen ? "translate-x-0" : "-translate-x-full"
          }`}
        >
          <br />
          <nav className="space-y-2 mt-[30px]">
            <NavLink
              to="/"
              className={({ isActive }) =>
                `flex items-center p-3 rounded-lg transition-colors duration-200 ${
                  isActive
                    ? "bg-blue-100 text-blue-700"
                    : "hover:bg-gray-100 text-gray-700"
                }`
              }
            >
              <Home className="mr-3" size={20} />
              Chat Window
            </NavLink>

            <NavLink
              to="/subjects"
              className={({ isActive }) =>
                `flex items-center p-3 rounded-lg transition-colors duration-200 ${
                  isActive
                    ? "bg-blue-100 text-blue-700"
                    : "hover:bg-gray-100 text-gray-700"
                }`
              }
            >
              <BookOpen className="mr-3" size={20} />
              Subject Selection
            </NavLink>

            <NavLink
              to="/bc"
              className={({ isActive }) =>
                `flex items-center p-3 rounded-lg transition-colors duration-200 ${
                  isActive
                    ? "bg-blue-100 text-blue-700"
                    : "hover:bg-gray-100 text-gray-700"
                }`
              }
            >
              <MessageCircle className="mr-3" size={20} />
              BC
            </NavLink>
            <NavLink
              to="/"
              onClick={LogIn}
              className={({ isActive }) =>
                `flex items-center p-3 rounded-lg transition-colors duration-200 ${
                  isActive
                    ? "hover:bg-red-50 text-gray-700"
                    : "hover:bg-red-50 text-gray-700"
                }`
              }
            >
              <MoveLeft className="mr-3" size={20} />
              Log In
            </NavLink>
          </nav>
        </div>

        <div
          className={`w-[90%] min-h-screen transition-all duration-300 ease-in-out ${
            isSidebarOpen ? "ml-[12%] " : "ml-0"
          }`}
        >
          <Routes>
            <Route path="/" element={<AIChatInterface />} />
            <Route path="/subjects" element={<BookBrowsingApp />} />
          </Routes>
        </div>
        <LoginModal isOpen={isLoginModalOpen} onClose={closeLoginModal} />
      </div>
    </Router>
  );
};

export default SidebarApp;
