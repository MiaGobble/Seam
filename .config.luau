type RuleName = string

type Config = {
	lute: {
		lint: {
			-- Array of globs (.gitignore style) to EXEMPT from linting
			ignores: { string }?,
			-- Table of string:unknown pairs; globals are passed down to each rule
			globals: { [string]: unknown }?,
			-- Array of paths from which to load local lint rules (similar to -r CLI option)
			rulepaths: { string }?,
			-- Specify per-rule options and overrides
			ruleconfigs: {
				[RuleName]: {
					-- Array of globs (.gitignore style) that are EXEMPT from this rule
					ignores: { string }?,
					-- Override a rule's default severity
					severity: ("warning" | "error" | "info" | "hint")?,
					-- Pass custom options through to a rule;
					-- see specific rule's implementation / docs for expected options structure
					options: { [string]: unknown }?,
					-- Disable a rule
					off: boolean?,
				},
			}?,
		}?,
	}?,
}

const config: Config = {
	lute = {
		lint = {
			ruleconfigs = {
				unused_variable = {
					off = true
				}
			}
		}
	}
}

return config