/**
 *  $.ajax({
 *      type: 'POST' or 'GET',
 *      url: '/' ie. '/helloWorld',
 *      success: (response) => {
 *          /// doSomething
 *          $('h1').text(JSON.stringify(response));
 *      }
 *  });
 * 
 *  $.ajax({
 *      type: 'GET',
 *      url: '/',
 *      success: (response) => {
 *          resolve();
 *      },
 *      error: (error) => {
 *          reject(error);
 *      }
 *  });
 */

/** */

const fetch = (url) => {
    return new Promise((resolve, reject) => {
        $.ajax({
            type: "GET",
            url: url,
            success: (response) => {
                resolve(response);
            },
            error: (error) => {
                reject(error);
            }
        });
    });
}

document.querySelector("body").classList.add("default-background-color");
document.querySelector("body").classList.add("default-text-color");

fetch("/navbar")
    .then((response) => {
        document.querySelector("header").innerHTML = response;
    });

setInterval(() => {
    console.log("");
}, 1000);