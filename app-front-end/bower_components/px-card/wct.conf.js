module.exports = {
    verbose: true,
    options: {remote: false, persistent: true},
    plugins: {
        local: {
            browsers: ['chrome','firefox']
        },
        sauce: {
            disabled: true
        }
    },
    suites:      ['test/*.html']
};