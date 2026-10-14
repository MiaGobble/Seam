return function(context)
	local describe = context.describe
	local it = context.it
	local expect = context.expect
	local Seam = context.Seam
	local Instance = context.Instance

	local StyleSheet = Seam.StyleSheet
	local New = Seam.New

	describe("StyleSheet", function()
		it("applies selectors and restores the previous properties", function()
			local root = Instance.new("Folder")
			root.Name = "Root"

			local title = Instance.new("TextLabel")
			title.Name = "TitleHeader"
			title.Text = "Old"
			title.Parent = root

			local other = Instance.new("TextLabel")
			other.Name = "Body"
			other.Text = "BodyOld"
			other.Parent = root

			local tagged = Instance.new("TextLabel")
			tagged.Name = "Badge"
			tagged.Text = "TagOld"
			tagged.Parent = root
			tagged:AddTag("Primary")

			local suffix = Instance.new("TextLabel")
			suffix.Name = "NameLabel"
			suffix.Text = "SuffixOld"
			suffix.Parent = root

			local sheet = StyleSheet.new()
			sheet:Style("TextLabel")({ Text = "Class" })
			sheet:Style("@TitleHeader")({ Text = "Exact" })
			sheet:Style("$Title")({ Text = "Prefix" })
			sheet:Style("Label$")({ Text = "Suffix" })
			sheet:Style("#Primary")({ Text = "Tagged" })

			sheet:Apply(root)
			expect(title.Text).toBe("Prefix")
			expect(other.Text).toBe("Class")
			expect(tagged.Text).toBe("Tagged")
			expect(suffix.Text).toBe("Suffix")

			local late = Instance.new("TextLabel")
			late.Name = "Body"
			late.Text = "Late"
			late.Parent = root
			context.fireEvent(root, "DescendantAdded", late)
			expect(late.Text).toBe("Class")

			sheet:Unapply(root)
			expect(title.Text).toBe("Old")
			expect(other.Text).toBe("BodyOld")
			expect(tagged.Text).toBe("TagOld")
			expect(suffix.Text).toBe("SuffixOld")
			expect(late.Text).toBe("Late")

			sheet:Apply(root)
			sheet:Destroy()
			expect(title.Text).toBe("Old")
		end)

		it("supports groups, inline rules, and New", function()
			local label = Instance.new("TextLabel")
			label.Text = "None"
			local root = Instance.new("Folder")
			label.Parent = root

			local sheet = StyleSheet.new()
			sheet:Style("TextLabel")({ Text = "Grouped" })
			local group = StyleSheet.group({ Dark = sheet })

			group(root, "Missing")
			expect(context.takeWarns()[1]).toContain("No stylesheet found")
			expect(label.Text).toBe("None")

			group(root, "Dark")
			expect(label.Text).toBe("Grouped")
			sheet:Unapply(root)

			StyleSheet(root, {
				{ Selector = "TextLabel", Properties = { Text = "Inline" } },
			})
			expect(label.Text).toBe("Inline")

			local fresh = Instance.new("Folder")
			label.Parent = fresh
			local hydrated = New(fresh, {
				[StyleSheet] = sheet,
			})
			expect(hydrated).toBe(fresh)
			expect(label.Text).toBe("Grouped")
			sheet:Destroy()
		end)

		it("warns for invalid stylesheets and properties", function()
			local folder = Instance.new("Folder")
			local sheet = StyleSheet.new()
			sheet:Style("Folder")({ ClassName = "Part" })
			sheet:Apply(folder)
			expect(context.takeWarns()[1]).toContain("Could not apply")

			StyleSheet(folder, "nope")
			expect(context.takeWarns()[2]).toContain("expects Seam.StyleSheet.new()")

			StyleSheet(folder, StyleSheet.group({ A = sheet }))
			expect(context.takeWarns()[3]).toContain("explicit key")
			sheet:Destroy()
		end)
	end)
end
