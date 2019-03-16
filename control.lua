--control.lua

labs = {}
labAnimations = {}
researchColors = {}
ingredientColors =
{
    ["automation-science-pack"] = {r = 1.0, g = 0.1, b = 0.1},
    ["logistic-science-pack"] =   {r = 0.1, g = 1.0, b = 0.1},
    ["chemical-science-pack"] =   {r = 0.2, g = 0.2, b = 1.0},
    ["military-science-pack"] =   {r = 0.0, g = 0.0, b = 0.0, a = 20.0},
    ["production-science-pack"] = {r = 0.8, g = 0.1, b = 0.8},
    ["utility-science-pack"] =    {r = 1.0, g = 0.9, b = 0.1},
    ["space-science-pack"] =      {r = 0.8, g = 0.8, b = 0.8} 
}

getColorsForResearch = function (tech)
    if tech == nil then
        return {}
    else
        if researchColors[tech] == nil then
            local colors = {}
            for index, ingredient in pairs(tech.research_unit_ingredients) do
                colors[index] = ingredientColors[ingredient.name]
            end
            researchColors[tech] = colors
        end
        return researchColors[tech]
    end
end

getColorsForForces = function ()
    local returnTable = {}
    for index, force in ipairs(game.forces) do
        returnTable[force] = getColorsForResearch(force.current_research)
    end
    return returnTable
end


script.on_event(
    {defines.events.on_tick},
    function (e)
        if e.tick % 300 == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just 1/second
            labs = game.surfaces[1].find_entities_filtered({type = "lab"})
            for index, lab in ipairs(labs) do
                if labAnimations[lab.unit_number] == nil then
                    labAnimations[lab.unit_number] = rendering.draw_animation({
                        animation = "discoscience/lab-storm",
                        surface = lab.surface,
                        target = lab.position,
                        render_layer = "higher-object-under",
                        -- animation_offset = math.random()*300,
                        -- animation_speed = 0.9 + math.random()*0.2
                    })
                end
                -- rendering.draw_light({
                --     intensity = 0.75,
                --     size = 8,
                --     color = {r = 1.0, g = 1.0, b = 1.0}
                -- })
            end
        end
        if e.tick %60 == 0 then
            -- local colorsForForces = getColorsForForces()
            for index, lab in ipairs(labs) do
                if lab.status == defines.entity_status.working or lab.status == defines.entity_status.low_power then
                    -- local colors = colorsForForces[lab.force];
                    local colors = getColorsForResearch(lab.force.current_research)
                    rendering.set_visible(labAnimations[lab.unit_number], true)
                    rendering.set_color(labAnimations[lab.unit_number], colors[math.random(#colors)])
                else
                    rendering.set_visible(labAnimations[lab.unit_number], false)
                end
            end
        end
    end
)