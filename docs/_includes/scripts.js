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

function toggleSiblingDiv(checkbox) {
    if (!checkbox)
        return;

    var siblingEl = checkbox.nextElementSibling;
    while (siblingEl && siblingEl.tagName.toLowerCase() !== 'div') {
        siblingEl = siblingEl.nextElementSibling;
    }
    if (!siblingEl)
        return;

    if (checkbox.checked) {
        siblingEl.classList.remove('w3-hide');
        siblingEl.classList.add('w3-show');
    } else {
        siblingEl.classList.remove('w3-show');
        siblingEl.classList.add('w3-hide');
    }
}