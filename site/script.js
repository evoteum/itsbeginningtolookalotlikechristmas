async function fetchCSVData(url) {
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
        const data = await response.text();

        const lines = data.split('\n').slice(1);
        const dates = [];
        const popularity = [];
        const xLabels = [];
        let lastWeekStart = null;

        lines.forEach(line => {
            const [date, pop] = line.split(',').map(item => item && item.trim());
            if (date && pop !== undefined) {
                const dateObj = new Date(date);
                const formattedDate = dateObj.toISOString().split('T')[0];
                dates.push(formattedDate);
                popularity.push(parseFloat(pop));

                if (dateObj.getMonth() === 11 && dateObj.getDate() === 25) {
                    xLabels.push("Merry Christmas! 🎅🥳");
                } else if (dateObj.getDay() === 1) {
                    xLabels.push(formattedDate);
                } else {
                    xLabels.push('');
                }
            }
        });

        return { dates, popularity, xLabels };
    } catch (error) {
        console.error("Error fetching CSV data:", error);
    }
}

async function renderChart() {
    const { dates, popularity, xLabels } = await fetchCSVData('data.csv');

    const ctx = document.getElementById('popularityChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: xLabels,
            datasets: [{
                label: 'Christmasyness %',
                data: popularity,
                borderColor: 'white',
                fill: false,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    title: { display: true, text: 'Date', color: 'white' },
                    ticks: { color: 'white' },
                    grid: { color: 'rgba(255, 255, 255, 0.2)' }
                },
                y: {
                    title: { display: true, text: 'Christmasyness %', color: 'white' },
                    ticks: { color: 'white' },
                    grid: { color: 'rgba(255, 255, 255, 0.2)' }
                }
            },
            plugins: {
                tooltip: {
                    callbacks: {
                        title: function(tooltipItems) {
                            const index = tooltipItems[0].dataIndex;
                            return dates[index];
                        },
                        label: function(tooltipItem) {
                            return `Christmasyness: ${tooltipItem.raw}%`;
                        }
                    }
                },
                backgroundColor: 'rgba(0, 0, 0, 0)'
            }
        }
    });
}

renderChart();