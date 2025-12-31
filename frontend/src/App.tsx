import { useState } from 'react'
import { UserProvider, useUser } from './contexts/UserContext'
import { ToastProvider } from './components/Toast'
import Game from './components/Game'
import TopBar from './components/TopBar'
import Chat from './components/Chat'
import Warehouse from './components/Warehouse'
import Market from './components/Market'
import StockExchange from './components/StockExchange'
import Auction from './pages/Auction'
import Login from './components/Login'

export type ModalType = 'warehouse' | 'market' | 'auction' | 'stock' | 'charity' | 'ranking' | 'blackmarket' | null

function GameContent() {
  const { user, loading, refreshProfile } = useUser()
  const [activeModal, setActiveModal] = useState<ModalType>(null)

  if (loading) {
    return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', background: '#1a4d1a', color: '#fff' }}>加载中...</div>
  }

  if (!user) {
    return <Login onSuccess={refreshProfile} />
  }

  return (
    <>
      <TopBar key={user?.gold} onMenuClick={setActiveModal} />
      <Game onOpenMarket={() => setActiveModal('market')} />
      <Chat />
      
      <Warehouse isOpen={activeModal === 'warehouse'} onClose={() => setActiveModal(null)} />
      <Market isOpen={activeModal === 'market'} onClose={() => setActiveModal(null)} />
      <StockExchange isOpen={activeModal === 'stock'} onClose={() => setActiveModal(null)} />
      {activeModal === 'auction' && (
        <div className="modal-overlay" onClick={() => setActiveModal(null)}>
          <div className="modal-content large" onClick={e => e.stopPropagation()}>
            <button className="modal-close" onClick={() => setActiveModal(null)}>×</button>
            <Auction />
          </div>
        </div>
      )}
    </>
  )
}

function App() {
  return (
    <UserProvider>
      <ToastProvider>
        <GameContent />
      </ToastProvider>
    </UserProvider>
  )
}

export default App
