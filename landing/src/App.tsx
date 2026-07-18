import { Hero } from './components/Hero'
import { HowItWorks } from './components/HowItWorks'
import { Navigation } from './components/Navigation'
import { WebExperience } from './components/WebExperience'
import { Faq } from './components/Faq'
import { Footer } from './components/Footer'
import { IndependenceNotice } from './components/IndependenceNotice'
import { TrustStrip } from './components/TrustStrip'

function App() {
  return (
    <div className="min-h-screen bg-canvas text-ink">
      <Navigation />
      <main id="main-content" tabIndex={-1}>
        <Hero />
        <TrustStrip />
        <HowItWorks />
        <WebExperience />
        <Faq />
        <IndependenceNotice />
      </main>
      <Footer />
    </div>
  )
}

export default App
