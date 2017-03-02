var path = require('path');
const webpack = require('webpack');

var BUILD_DIR = path.resolve(__dirname, 'public');
var APP_DIR = path.resolve(__dirname, 'public');

var config = {
    entry: APP_DIR + '/swiftRoomClient.js',
    output: {
        filename: 'js/bundle.js',
        path: BUILD_DIR
    },
    module : {
        loaders : []
    },
    plugins: [
        new webpack.optimize.UglifyJsPlugin({
            sourceMap: true, 
            beautify: false,
            compress: {
                screw_ie8: true,
                warnings: false 
            },
            comments: false
        })
    ]
};

module.exports = config;
