// Get all the our-concept elements
const ourConcepts = document.querySelectorAll('.our-concept');

// Add a click event listener to each our-concept element
ourConcepts.forEach((ourConcept) => {
  ourConcept.addEventListener('click', function() {
    if (this.classList.contains('opened')) {
      this.classList.remove('opened');
      this.classList.add('closed');
    } else if (this.classList.contains('closed')) {
      this.classList.remove('closed');
    } else {
      this.classList.add('opened');
    }
  });
});
