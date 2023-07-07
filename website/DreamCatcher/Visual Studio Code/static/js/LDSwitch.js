// JavaScript for theme switcher

const themeToggle = document.getElementById('theme-toggle');
const body = document.body;

themeToggle.addEventListener('change', function() {
    body.classList.toggle('dark-theme');
});
