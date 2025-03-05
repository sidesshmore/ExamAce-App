import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import AIChatInterface from './playground'
import BookBrowsingApp from './Subject'
import SidebarApp from './Sidebar'
import { Sidebar } from 'lucide-react'
import BookNav from './BookNav'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      {/* <AIChatInterface /> */}
      {/* <BookBrowsingApp /> */}
      <SidebarApp />
      {/* <BookNav /> */}

    </>
  )
}

export default App
