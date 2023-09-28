-- Extra plugins from LazyVim
return {
	-- File Previews
	{ import = "lazyvim.plugins.extras.editor.mini-files" },

	-- Goodies for the UI
	{ import = "lazyvim.plugins.extras.ui.mini-animate" },
	{ import = "lazyvim.plugins.extras.ui.mini-starter" },

	-- Project handling
	{ import = "lazyvim.plugins.extras.util.project" },

	-- Languages
	{ import = "lazyvim.plugins.extras.lang.go" },
	{ import = "lazyvim.plugins.extras.lang.docker" },
	{ import = "lazyvim.plugins.extras.lang.java" },
	{ import = "lazyvim.plugins.extras.lang.yaml" },

	-- Testing with NeoTest
	{ import = "lazyvim.plugins.extras.test.core" },

	-- Debuggers Adapter
	{ import = "lazyvim.plugins.extras.dap.core" },
}
