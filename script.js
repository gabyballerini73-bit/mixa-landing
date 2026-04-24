/* ═══════════════════════════════════════════════
   MiXa Mining Intelligence — Landing Page Scripts
   ═══════════════════════════════════════════════ */

/* ── NAVBAR: scroll state & mobile toggle ──── */
const navbar   = document.getElementById('navbar');
const navToggle = document.getElementById('navToggle');
const navLinks  = document.getElementById('navLinks');

window.addEventListener('scroll', () => {
  navbar.classList.toggle('scrolled', window.scrollY > 40);
}, { passive: true });

navToggle.addEventListener('click', () => {
  const isOpen = navLinks.classList.toggle('open');
  navToggle.setAttribute('aria-expanded', isOpen);
});

// Close mobile menu on link click
navLinks.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => {
    navLinks.classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
  });
});

// Close on outside click
document.addEventListener('click', (e) => {
  if (!navbar.contains(e.target)) {
    navLinks.classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
  }
});

/* ── SCROLL REVEAL (Intersection Observer) ── */
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      revealObserver.unobserve(entry.target);
    }
  });
}, {
  threshold: 0.12,
  rootMargin: '0px 0px -40px 0px'
});

document.querySelectorAll('.reveal').forEach(el => {
  revealObserver.observe(el);
});

/* ── SMOOTH SCROLL for anchor links ─────────── */
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    const target = document.querySelector(this.getAttribute('href'));
    if (!target) return;
    e.preventDefault();
    const navHeight = navbar.offsetHeight;
    const targetY = target.getBoundingClientRect().top + window.scrollY - navHeight - 16;
    window.scrollTo({ top: targetY, behavior: 'smooth' });
  });
});

/* ── ACTIVE NAV LINK on scroll ───────────────── */
const sections = document.querySelectorAll('section[id]');
const navAnchors = document.querySelectorAll('.nav-links a[href^="#"]');

const activeObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      navAnchors.forEach(a => a.classList.remove('active'));
      const id = entry.target.getAttribute('id');
      const activeLink = document.querySelector(`.nav-links a[href="#${id}"]`);
      if (activeLink) activeLink.classList.add('active');
    }
  });
}, {
  threshold: 0.35,
  rootMargin: `-${navbar.offsetHeight}px 0px 0px 0px`
});

sections.forEach(s => activeObserver.observe(s));

/* ── CONTACT FORM: basic feedback ───────────── */
const form = document.querySelector('.contact-form');
if (form) {
  form.addEventListener('submit', async (e) => {
    const btn = form.querySelector('.btn-submit');
    const originalText = btn.textContent;

    // If Netlify Forms are handling it, let it submit normally.
    // Only intercept for JS-only environments (dev preview).
    if (!form.dataset.netlify) {
      e.preventDefault();
      btn.textContent = 'Enviando...';
      btn.disabled = true;
      await new Promise(r => setTimeout(r, 1500));
      btn.textContent = '¡Mensaje enviado!';
      setTimeout(() => {
        btn.textContent = originalText;
        btn.disabled = false;
        form.reset();
      }, 3000);
    } else {
      btn.textContent = 'Enviando...';
      btn.disabled = true;
    }
  });
}

/* ── LAYER EXPAND/COLLAPSE on mobile ────────── */
if (window.innerWidth < 600) {
  document.querySelectorAll('.layer-header').forEach(header => {
    const layer = header.closest('.layer');
    const services = layer.querySelector('.layer-services') || layer.querySelector('.ai-flow');
    if (!services) return;

    header.style.cursor = 'pointer';
    header.setAttribute('role', 'button');
    header.setAttribute('aria-expanded', 'true');

    header.addEventListener('click', () => {
      const isOpen = services.style.display !== 'none';
      services.style.display = isOpen ? 'none' : '';
      header.setAttribute('aria-expanded', !isOpen);
    });
  });
}

/* ── FORMULA COUNTER ANIMATION ───────────────── */
const formulaObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.querySelectorAll('.formula-term').forEach((term, i) => {
        term.style.transitionDelay = `${i * 0.12}s`;
        term.style.opacity = '0';
        term.style.transform = 'translateY(16px)';
        term.style.transition = 'opacity .5s ease, transform .5s ease';
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            term.style.opacity = '1';
            term.style.transform = 'translateY(0)';
          });
        });
      });
      formulaObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.4 });

const formulaWrap = document.querySelector('.formula-wrap');
if (formulaWrap) formulaObserver.observe(formulaWrap);
