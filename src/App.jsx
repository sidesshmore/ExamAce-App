import { useState } from "react";
import viteLogo from "/vite.svg";
import "./App.css";
import AIChatInterface from "./playground";
import BookBrowsingApp from "./Subject";
import SidebarApp from "./Sidebar";
import { Sidebar } from "lucide-react";
import BookNav from "./BookNav";

function App() {
  return (
    <>
      {/* <AIChatInterface /> */}
      {/* <BookBrowsingApp /> */}
      <SidebarApp />
      {/* <BookNav /> */}
    </>
  );
}

export default App;
