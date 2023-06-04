const carousel = document.querySelector('.');
const slides = carousel.querySelectorAll('img');

let currentSlide = 0;
const slideInterval = setInterval(nextSlide, 5000); // change slide every 5 seconds

function nextSlide() {
  slides[currentSlide].classList.remove('active');
  currentSlide = (currentSlide + 1) % slides.length;
  slides[currentSlide].classList.add('active');
  carousel.style.transform = `translateX(-${currentSlide * 100}%)`;
}