'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const glob = require('glob');
const compiler = require('node-elm-compiler');
const errorFile = require.resolve('./Errors.elm');

class ElmLangCompiler {
    _parse (filename, fallback) {
        try {
            return JSON.parse(fs.readFileSync(filename, 'utf8'));
        } catch (error) {
            return fallback;
        }
    }

    _module (file) {
        return this.config['source-directories'].filter(source => {
            return file.path.startsWith(source);
        }).map(source => {
            return file.path.slice(source.length);
        }).map(module => {
            return path.parse(module);
        }).map(module => {
            return path.join(module.dir.slice(1), module.name);
        })[0];
    }

    _compile (file) {
        return compiler.compileToString(file.path, this.config.compilerOptions);
    }

    constructor (config) {
        this.config = {
            compilerOptions: {
                debug: true
            },
            renderErrors: false,
            'exposed-modules': [],
            'source-directories': []
        };
        
        let local = this._parse('elm.json', {
            'source-directories': ['app']
        });
        
        this.config['source-directories'] = local['source-directories'] || [];

        config = config && config.plugins && config.plugins.elm || {};
        this.config = Object.assign(this.config, config);
    }

    getDependencies (file) {
        return compiler.findAllDependencies(file.path);
    }

    compile (file) {
        let module = this._module(file);

        if (this.config['exposed-modules'].indexOf(module) < 0) {
            return Promise.resolve(null);
        } else {
            return this._compile.call(this, file)
                    .then((js) => {
                        file.data = js;
                        return file;
                    });
        }
    }

}

ElmLangCompiler.prototype.brunchPlugin = true;
ElmLangCompiler.prototype.type = 'javascript';
ElmLangCompiler.prototype.extension = 'elm';

module.exports = ElmLangCompiler;
