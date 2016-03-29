suite('<px-simple-line-chart>', function() {
    test('is awesomest', function() {
        console.log(document);
        console.log(document.getElementById('fixture').attributes.awesomest.value);
        assert.isTrue(document.getElementById('fixture').attributes.awesomest.value == '');
    });
});

mocha.run();
