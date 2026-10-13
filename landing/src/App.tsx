import { Hero } from './components/Hero'
import { HowItWorks } from './components/HowItWorks'
import { Navigation } from './components/Navigation'
import { Footer } from './components/Footer'
import { IndependenceNotice } from './components/IndependenceNotice'
import { SupportSection } from './components/SupportSection'

function App() {
  return (
    <div className="min-h-screen bg-canvas text-ink">
      <Navigation />
      <main id="main-content" tabIndex={-1}>
        <Hero />
        <HowItWorks />
        <SupportSection />
        <IndependenceNotice />
      </main>
      <Footer />
    </div>
  )
}

export default App
