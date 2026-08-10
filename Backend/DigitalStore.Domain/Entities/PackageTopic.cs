namespace DigitalStore.Domain.Entities
{
    public class PackageTopic
    {
        public int Id { get; set; }
        public int PackageId { get; set; }
        public int TopicId { get; set; }

        public Package Package { get; set; } = null!;
        public Topic Topic { get; set; } = null!;
    }
}
