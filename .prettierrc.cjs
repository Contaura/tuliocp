// Helper function to safely load plugins
function tryLoadPlugins(plugins) {
	const availablePlugins = [];
	for (const plugin of plugins) {
		try {
			require.resolve(plugin);
			availablePlugins.push(plugin);
		} catch (e) {
			console.warn(`Prettier plugin ${plugin} not available, skipping`);
		}
	}
	return availablePlugins;
}

module.exports = {
	// Plugins - conditionally load only if available
	plugins: [
		// Core plugins that should be available
		...tryLoadPlugins([
			'@prettier/plugin-php',
			'prettier-plugin-nginx',
			'prettier-plugin-sh',
			'prettier-plugin-sql',
		]),
	],
	// PHP Settings
	phpVersion: '8.2',
	braceStyle: '1tbs',
	endOfLine: 'lf',

	// Overrides for some files
	overrides: [
		// JavaScript files
		{
			files: ['*.{js,cjs}'],
			options: {
				singleQuote: true,
			},
		},
		// Tulio CLI
		{
			files: ['bin/v-*', 'src/deb/*/{postinst,preinst,tulio,postrm}', 'install/common/api/*'],
			options: {
				parser: 'sh',
			},
		},
		// Nginx config
		{
			files: ['**/nginx/*.inc', '**/nginx/*.conf'],
			options: {
				parser: 'nginx',
				wrapParameters: false,
			},
		},
	],
};
