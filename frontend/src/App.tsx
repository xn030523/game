import { useState } from 'react'
import { UserProvider } from './contexts/UserContext'
import Game from './components/Game'
import TopBar from './components/TopBar'
import Chat from './components/Chat'
import Warehouse from './components/Warehouse'
import Market from './components/Market'
import StockExchange from './components/StockExchange'

export type ModalType = 'warehouse' | 'market' | 'auction' | 'stock' | 'charity' | 'ranking' | 'blackmarket' | null

function App() {
  const [activeModal, setActiveModal] = useState<ModalType>(null)

  return (
    <UserProvider>
      <TopBar onMenuClick={setActiveModal} />
      <Game />
      <Chat />
      
      <Warehouse isOpen={activeModal === 'warehouse'} onClose={() => setActiveModal(null)} />
      <Market isOpen={activeModal === 'market'} onClose={() => setActiveModal(null)} />
      <StockExchange isOpen={activeModal === 'stock'} onClose={() => setActiveModal(null)} />
    </UserProvider>
  )
}

export default App
