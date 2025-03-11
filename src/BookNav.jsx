import React from "react";
import { useNavigate } from "react-router-dom";
import BookBrowsingApp from "./Subject";
import AIChatInterface from "./playground";

const BookNav = () => {
  return (
    <Router>
      <Routes>
        <Route path="/book/:bookId" element={<AIChatInterface />} />
      </Routes>
    </Router>
  );
};

export default BookNav;
