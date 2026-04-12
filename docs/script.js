const commands = [
    { name: 'Update-PowerConfig', desc: 'Pull latest changes from GitHub' },
    { name: 'Show-PowerDocs', desc: 'Open this documentation site' },
    { name: 'winutil', desc: 'Launch Chris Titus Tech Utility' },
    { name: 'Get-MyIP', desc: 'Display all IP addresses' },
    { name: 'Invoke-HttpBench', desc: 'URL performance benchmark' },
    { name: 'Convert-VideoToMp4', desc: 'Video transcoding (FFmpeg)' },
    { name: 'Extract-Audio', desc: 'Audio extraction (FFmpeg)' },
    { name: 'Get-FileHashes-All', desc: 'Multi-algorithm hash check' },
    { name: 'Protect-File', desc: 'Secure file encryption' },
    { name: 'Get-DuplicateFiles', desc: 'Find duplicate files by hash' },
    { name: 'Invoke-Rename-Lower', desc: 'Bulk lowercase rename' },
    { name: 'pinstall', desc: 'Universal package installer' }
];

const tableBody = document.querySelector('#cmd-table tbody');
const searchInput = document.querySelector('#cmd-search');

function renderTable(filter = '') {
    tableBody.innerHTML = '';
    const filtered = commands.filter(c => 
        c.name.toLowerCase().includes(filter.toLowerCase()) || 
        c.desc.toLowerCase().includes(filter.toLowerCase())
    );

    filtered.forEach(c => {
        const row = `<tr>
            <td><code>${c.name}</code></td>
            <td>${c.desc}</td>
        </tr>`;
        tableBody.insertAdjacentHTML('beforeend', row);
    });
}

searchInput.addEventListener('input', (e) => {
    renderTable(e.target.value);
});

renderTable();
