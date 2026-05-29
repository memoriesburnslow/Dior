const express = require('express');
const fs = require('fs');
const { Client, GatewayIntentBits, REST, Routes, SlashCommandBuilder } = require('discord.js');
const app = express();
app.use(express.json());

const dbFile = './keys.json';

if (!fs.existsSync(dbFile)) {
    fs.writeFileSync(dbFile, JSON.stringify({}));
}

// ================= ROBLOX SERVER INTERFACE =================
app.get('/verify', (req, res) => {
    const { key, hwid } = req.query;
    let keys = JSON.parse(fs.readFileSync(dbFile));

    if (!key || !keys[key]) {
        return res.send("Invalid");
    }

    if (keys[key].hwid === null) {
        keys[key].hwid = hwid;
        fs.writeFileSync(dbFile, JSON.stringify(keys, null, 2));
        return res.send("Success");
    }

    if (keys[key].hwid !== hwid) {
        return res.send("HWID_Mismatch");
    }

    res.send("Success");
});

app.listen(3000, () => {
    console.log("Roblox server interface is active on port 3000!");
});

// ================= DISCORD BOT SETUP =================
// ENTER YOUR DISCORD DATA HERE:
const BOT_TOKEN = "MTUxMDAyMjQyNzc3MjQ1MzAxNA.GbBdgj.4fAfRDRYBNbpd2tQAqhM4n4oMzGNnvwbrSzBEM"; 
const CLIENT_ID = "1510022427772453014"; 
const ALLOWED_ROLE_ID = "1510025114060849162"; 

const client = new Client({ intents: [GatewayIntentBits.Guilds] });

// Function to generate a secure, 15-character key
function generateRandomKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < 15; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

// Slash-Command Definition
const commands = [
    new SlashCommandBuilder()
        .setName('generate-key')
        .setDescription('Generates secure keys for the Roblox script')
        .addIntegerOption(option => 
            option.setName('amount')
                .setDescription('How many keys do you want to generate?')
                .setRequired(true)
                .setMinValue(1)
                .setMaxValue(50) // Anti-spam protection
        )
].map(command => command.toJSON());

// Registering commands with Discord
const rest = new REST({ version: '10' }).setToken(BOT_TOKEN);

(async () => {
    try {
        console.log('Started refreshing application (/) commands...');
        await rest.put(
            Routes.applicationCommands(CLIENT_ID),
            { body: commands },
        );
        console.log('Successfully reloaded application (/) commands!');
    } catch (error) {
        console.error('Error while registering commands:', error);
    }
})();

client.on('ready', () => {
    console.log(`Bot is logged in and online as ${client.user.tag}!`);
});

// Handling Interaction (Slash-Commands)
client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return;

    if (interaction.commandName === 'generate-key') {
        // Permission Check
        if (!interaction.member.roles.cache.has(ALLOWED_ROLE_ID)) {
            return interaction.reply({ content: "❌ You do not have permission to generate keys!", ephemeral: true });
        }

        const amount = interaction.options.getInteger('amount');
        let keys = JSON.parse(fs.readFileSync(dbFile));
        let generatedKeys = [];

        // Generate requested amount of keys
        for (let i = 0; i < amount; i++) {
            let newKey = generateRandomKey();
            // If the key accidentally exists already, roll a new one
            while (keys[newKey]) {
                newKey = generateRandomKey();
            }
            keys[newKey] = { hwid: null };
            generatedKeys.push(newKey);
        }

        // Save into keys.json
        fs.writeFileSync(dbFile, JSON.stringify(keys, null, 2));

        // Formatted message for Discord
        const keyList = generatedKeys.map(k => `🔑 \`${k}\``).join('\n');
        await interaction.reply({
            content: `✅ **Successfully generated ${amount} key(s):**\n\n${keyList}`,
            ephemeral: true // Only visible to the admin who ran the command
        });
    }
});

// Start the bot
client.login(BOT_TOKEN).catch(err => console.log("Discord Login Error: " + err));
