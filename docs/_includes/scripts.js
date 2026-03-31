function copySiblingCodeToClipboard(button) {
    if (!button)
        return;

    const siblingCode = button.nextElementSibling;
    if (siblingCode && siblingCode.tagName.toLowerCase() === 'code') {
        console.log(siblingCode);
        const codeText = siblingCode.innerText;
        console.log(codeText);
        navigator.clipboard.writeText(codeText).then(() => {
            // Optionally, you can provide feedback to the user here, such as changing the button text temporarily
            //const originalText = button.innerText;
            //button.innerText = 'Copied!';
            //setTimeout(() => {
               //button.innerText = originalText;
            //}, 2000);
        }).catch(err => {
            console.error('Failed to copy text: ', err);
        });
    }
}