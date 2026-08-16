import React from "react";
import { createRoot } from "react-dom/client";
import "./styles.css";

const Arrow = () => <span aria-hidden="true">↗</span>;

function App() {
  return (
    <>
      {/* ══════════ HEADER ══════════ */}
      <header className="navbar">
        <a href="#home" className="brand" aria-label="Dexter home">
          <span className="code-icon">&lt;/&gt;</span> Dexter Platform
        </a>

        <nav aria-label="Primary navigation">
          <a href="#about">About</a>
          <a href="#experience">Experience</a>
          <a href="#skills">Skills</a>
          <a href="#contact">Contact</a>
          <a href="#contact" className="btn-connect">✈ Let's Connect</a>
        </nav>
      </header>

      <main>
        {/* ══════════ HERO ══════════
            Header is intentionally outside the hero so it never overlays
            or dims the artwork. The hero itself is split into a blue
            content panel and a full-height, borderless image panel.
        */}
        <section id="home" className="hero">
          <div className="hero-copy">
            <p className="eyebrow">Hi, I'm Arun 👋</p>

            <h1>
              I build. I learn.
              <br />
              <em>I share.</em>
            </h1>

            <p className="intro">
              I design and build reliable technology solutions across backend
              systems, cloud platforms and enterprise integrations.
            </p>

            <div className="links">
              <a href="#about" className="btn-primary">👤 View My Work</a>
              <a href="mailto:aaarunshiv111@gmail.com" className="btn-outline">
                ✉ Let's Connect
              </a>
            </div>

            <div className="social-links">
              <span>Connect with me</span>

              <a
                href="https://github.com/arunsivadas11"
                target="_blank"
                rel="noopener noreferrer"
                className="social-icon"
                aria-label="GitHub"
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"/>
                </svg>
              </a>

              <a
                href="https://www.linkedin.com/in/arunsivadas11/"
                target="_blank"
                rel="noopener noreferrer"
                className="social-icon"
                aria-label="LinkedIn"
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 01-2.063-2.065 2.064 2.064 0 112.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2.774 22.222 0h.003z"/>
                </svg>
              </a>

              <a
                href="mailto:aaarunshiv111@gmail.com"
                className="social-icon"
                aria-label="Email"
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
                </svg>
              </a>
            </div>
          </div>

          <div className="hero-art" aria-hidden="true">
            <img
              src="/Dexter-Platform.png"
              alt=""
              className="hero-image"
            />
          </div>
        </section>

        {/* ══════════ ABOUT ══════════ */}
        <section id="about" className="about-section">
          <div className="about-left">
            <h2>About Me</h2>
            <div className="accent-line" />

            <p className="about-intro">
              I am a Solutions Architect with over 12 years of experience in
              software engineering, specializing in backend systems, cloud
              technologies, enterprise integrations and solution design.
            </p>

            <p className="about-intro">
              I work with architects, development teams and business
              stakeholders to define scalable, resilient and maintainable
              solutions.
            </p>

            <a href="#contact" className="btn-outline-sm">👤 More About Me</a>
          </div>

          <div className="about-right">
            <div className="trait-card">
              <div className="trait-icon blue-icon">💡</div>
              <h3>Solution Designer</h3>
              <p>
                I design comprehensive solutions for complex engineering
                challenges and scalable systems.
              </p>
            </div>

            <div className="trait-card">
              <div className="trait-icon green-icon">&lt;/&gt;</div>
              <h3>Backend Engineer</h3>
              <p>
                I build robust, maintainable backend systems with focus on
                performance and reliability.
              </p>
            </div>

            <div className="trait-card">
              <div className="trait-icon purple-icon">📚</div>
              <h3>Lifelong Learner</h3>
              <p>
                Always learning, exploring, and staying curious about emerging
                technologies and practices.
              </p>
            </div>

            <div className="trait-card">
              <div className="trait-icon orange-icon">☁️</div>
              <h3>Cloud Architect</h3>
              <p>
                I architect cloud solutions using modern technologies and
                enterprise integration patterns.
              </p>
            </div>
          </div>
        </section>

        {/* ══════════ WHAT I DO ══════════ */}
        <section id="experience" className="what-section">
          <h2>What I Do</h2>
          <div className="accent-line" />

          <div className="what-grid">
            <div className="what-card">
              <div className="what-icon blue-bg">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="currentColor">
                  <rect x="2" y="3" width="20" height="14" rx="2"/>
                  <path d="M8 21h8M12 17v4" stroke="white" strokeWidth="2" fill="none"/>
                </svg>
              </div>
              <div>
                <h3>Build</h3>
                <p>
                  I build modern web applications with focus on performance,
                  usability, and scalability.
                </p>
                <a href="#contact" className="card-link">View Projects <Arrow /></a>
              </div>
            </div>

            <div className="what-card">
              <div className="what-icon green-bg">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path d="M4 19.5A2.5 2.5 0 016.5 17H20"/>
                  <path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/>
                </svg>
              </div>
              <div>
                <h3>Learn</h3>
                <p>
                  I constantly explore new tools, frameworks, and best
                  practices to level up.
                </p>
                <a href="#contact" className="card-link green-link">Read My Blog <Arrow /></a>
              </div>
            </div>

            <div className="what-card">
              <div className="what-icon orange-bg">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <circle cx="18" cy="5" r="3"/>
                  <circle cx="6" cy="12" r="3"/>
                  <circle cx="18" cy="19" r="3"/>
                  <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
                  <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
                </svg>
              </div>
              <div>
                <h3>Share</h3>
                <p>
                  I write about my learnings and share insights to help others
                  on their journey.
                </p>
                <a href="#contact" className="card-link orange-link">Explore Articles <Arrow /></a>
              </div>
            </div>
          </div>
        </section>

        {/* ══════════ EXPERIENCE + SKILLS ══════════ */}
        <section id="skills" className="skills-section">
          <h2>Experience</h2>
          <div className="accent-line" />

          <div className="experience-list">
            <div className="exp-item">
              <h3>Renault Group</h3>
              <p className="role">Solutions Architect · Supply Chain IT</p>
              <p className="prev">Technical Lead · Engineering IT</p>
            </div>

            <div className="exp-item">
              <h3>Wipro Technologies</h3>
              <p className="role">Developer · Senior Developer</p>
              <p className="prev">Corporate Banking · Standard Bank of South Africa</p>
            </div>
          </div>

          <h2 style={{ marginTop: "60px" }}>Focus Areas</h2>
          <div className="accent-line" />

          <div className="skills">
            {[
              "Java",
              "Spring Boot",
              "GCP",
              "Hibernate",
              "APIs",
              "Enterprise Integration",
              "Solution Design",
              "Performance",
            ].map((x) => (
              <span key={x}>{x}</span>
            ))}
          </div>
        </section>

        {/* ══════════ CONTACT ══════════ */}
        <section id="contact" className="contact-section">
          <span className="footer-heart">❤️</span>
          <h2>
            Let's build something
            <br />
            <em>amazing together.</em>
          </h2>

          <p>
            Open to conversations around architecture, engineering and
            technology.
          </p>

          <div className="contact-links">
            <a href="mailto:aaarunshiv111@gmail.com">Email <Arrow /></a>
            <a
              href="https://www.linkedin.com/in/arunsivadas11/"
              target="_blank"
              rel="noopener noreferrer"
            >
              LinkedIn <Arrow />
            </a>
            <a
              href="https://github.com/arunsivadas11"
              target="_blank"
              rel="noopener noreferrer"
            >
              GitHub <Arrow />
            </a>
          </div>
        </section>
      </main>

      <footer>
        <p>Thanks for stopping by! Let's build something amazing together.</p>
        <p className="copyright">© 2026 Dexter Platform. All rights reserved.</p>
      </footer>
    </>
  );
}

createRoot(document.getElementById("root")).render(<App />);
