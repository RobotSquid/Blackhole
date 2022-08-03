#include <SFML/Graphics.hpp>
#include <bits/stdc++.h>

int main() {
	const int w = 1800;
	const int h = 900;

	float r = 0;
	sf::ContextSettings settings;
	settings.antialiasingLevel = 4;
    sf::RenderWindow window(sf::VideoMode(w, h), "Black Hole Renderer", sf::Style::Default, settings);
	window.setFramerateLimit(60);
    sf::Texture texture;
	texture.create(w, h);
	sf::Sprite sprite(texture);
	sf::Texture discTex;
    discTex.loadFromFile("adisk.jpg");
	sf::Texture skyTex;
    skyTex.loadFromFile("stars.jpg");

	if (!sf::Shader::isAvailable()) window.close();

	sf::Shader shader;
	if (!shader.loadFromFile("frag.glsl", sf::Shader::Fragment)) window.close();

	shader.setUniform("RES", sf::Vector2f(w, h));
	shader.setUniform("FOV_DIST", 0.7f);
	shader.setUniform("STEP", 0.2f);
	shader.setUniform("ITER", 1000);
	shader.setParameter("DISC_TEX", discTex);
	shader.setParameter("SKY_TEX", skyTex);
	shader.setUniform("GRAV", 1.0f);

    while (window.isOpen()) {
		sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed) window.close();
        }
		r += 0.002;
		if (r > 2*3.1415926f) r = 0;
		
		shader.setUniform("CAM_POS", sf::Vector3f(-(8-2*sin(r))*sin(r), 1.2+sin(r), (8-2*sin(r))*cos(r)));
		shader.setUniform("CAM_ROT", sf::Glsl::Vec4(cos(0.5*r), 0, sin(0.5*r), 0));
		shader.setUniform("DISC_ROT", (r / (3.1415926f / 2)));
		window.clear();
		window.draw(sprite, &shader);
        window.display();
    }
    return 0;
}