import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import AIChatInterface from "./playground";

// Mock data for book subjects and books
const SUBJECTS = [
  "CSC601- Data Analytics and Visualization",
  "CSC602- Cryptography and System Security",
  "CSC603- Software Engineering and Project Management",
  "CSC604- Machine Learning",
];

const BOOKS = {
  "CSC602- Cryptography and System Security": [
    {
      id: 1,
      title: "Web Application Hackers Handbook",
      cover:
        "https://m.media-amazon.com/images/I/51mzEbU-nBL._UF1000,1000_QL80_.jpg",
    },
    {
      id: 2,
      title: "Notes on Cryptography",
      cover:
        "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/notes-template-design-9d18fb23558d6331c1f545bcb17fd6c3_screen.jpg?ts=1645871443",
    },
  ],
  "CSC601- Data Analytics and Visualization": [
    {
      id: 3,
      title:
        " Data Science and Big Data Analytics: Discovering, Analyzing, Visualizing and Presenting Data,EMC Education services Wiley Publication",
      cover: "https://m.media-amazon.com/images/I/61VdqcWYcxL.jpg",
    },
    {
      id: 4,
      title: "Notes on Data Analytics and Visualisation",
      cover:
        "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/notes-template-design-9d18fb23558d6331c1f545bcb17fd6c3_screen.jpg?ts=1645871443",
    },
  ],
  "CSC603- Software Engineering and Project Management": [
    {
      id: 5,
      title:
        "Roger S. Pressman, Software Engineering: A practitioner's approach",
      cover:
        "https://m.media-amazon.com/images/I/816xr5ywK9L._AC_UF1000,1000_QL80_.jpg",
    },
    {
      id: 6,
      title: "Notes on Cryptography",
      cover:
        "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/notes-template-design-9d18fb23558d6331c1f545bcb17fd6c3_screen.jpg?ts=1645871443",
    },
  ],
};

const BookBrowsingApp = () => {
  const [selectedSubject, setSelectedSubject] = useState(
    "CSC601- Data Analytics and Visualization"
  );

  // Use navigate hook for routing
  const navigate = useNavigate();

  // Handler for book image click
  const handleBookClick = (book) => {
    // Navigate to AI Chat interface with book ID
    navigate(`/`, console.log(book));
  };

  // Get books for the selected subject, default to empty array if not found
  const booksForSubject = BOOKS[selectedSubject] || [];

  return (
    <div className="container w-[80%] mx-auto p-6 ml-[20%]">
      <h1 className="text-3xl font-bold mb-6">ExamAce Library</h1>

      {/* Subject Dropdown */}
      <div className="mb-6">
        <label
          htmlFor="subject-select"
          className="block mb-2 text-sm font-medium"
        >
          Select a Subject
        </label>
        <select
          id="subject-select"
          value={selectedSubject}
          onChange={(e) => setSelectedSubject(e.target.value)}
          className="
            w-full 
            p-2 
            border 
            rounded-md 
            bg-white             
            text-black           
            border-gray-300      
            hover:bg-gray-100    
            focus:outline-none   
            focus:ring-2         
            focus:ring-gray-200  
          "
        >
          {SUBJECTS.map((subject) => (
            <option
              key={subject}
              value={subject}
              className="text-black bg-white"
            >
              {subject}
            </option>
          ))}
        </select>
      </div>

      {/* Book Thumbnail Grid or No Books Message */}
      {booksForSubject.length > 0 ? (
        <div className="grid grid-cols-4 gap-6">
          {booksForSubject.map((book) => (
            <div
              key={book.id}
              className="border rounded-lg overflow-hidden shadow-md hover:shadow-xl transition-shadow cursor-pointer"
              onClick={() => handleBookClick(book)}
            >
              <img
                src={book.cover}
                alt={book.title}
                className="w-full h-96 object-cover"
              />
              <div className="p-4">
                <h3 className="font-bold text-lg truncate">{book.title}</h3>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-10 bg-gray-100 rounded-lg">
          <p className="text-gray-600">No books available for this subject.</p>
        </div>
      )}
    </div>
  );
};

export default BookBrowsingApp;
