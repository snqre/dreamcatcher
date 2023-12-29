export default function fetch(url) {
    return new Promise((resolve, reject) => {
        $.ajax({
            type: 'GET',
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