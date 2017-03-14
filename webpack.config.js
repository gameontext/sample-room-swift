var path = require('path');
const webpack = require('webpack');

var BUILD_DIR = path.resolve(__dirname, 'public');
var APP_DIR = path.resolve(__dirname, 'client/app');

var config = {
    entry: APP_DIR + '/gameOnSwift.js',
    output: {
        filename: 'js/bundle.js',
        path: BUILD_DIR
    },
    module : {
        loaders : [
            {
                test    : /\.jsx?/,
                include : APP_DIR,
                loader  : 'babel-loader'
            },
            {
                test: /\.scss$/,
                loader: 'style!css!sass'
            },
            { 
                test: /\.css$/, 
                loader: "style-loader!css-loader" 
            },
            {
                test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/, 
                loader: 'url?limit=10000&mimetype=application/font-woff'
            },
            {
                test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/, 
                loader: 'url?limit=10000&mimetype=application/octet-stream'
            },
            {
                test: /\.eot(\?v=\d+\.\d+\.\d+)?$/, 
                loader: 'file'
            },
            {
                test: /\.svg(\?v=\d+\.\d+\.\d+)?$/, 
                loader: 'url?limit=10000&mimetype=image/svg+xml'
            }
        ]
    }
};

module.exports = config;
