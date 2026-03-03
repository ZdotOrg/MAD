ListView.builder(
  itemCount: sampleRecipes.length,
  itemBuilder: (context, index) {
    final recipe = sampleRecipes[index];
    return Card(
      child: ListTile(
        leading: Image.asset(recipe.imagePath, width: 56, fit: BoxFit.cover),
        title:   Text(recipe.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(recipe: recipe),
            ),
          );
        },
      ),
    );
  },
)