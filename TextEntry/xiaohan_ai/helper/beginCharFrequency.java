import java.io.*;
import java.util.*;

public class beginCharFrequency {
    public static void main(String[] args) throws Exception {
        String fileName = "terms2.txt";
        FileReader fr = null;
        BufferedReader br = null;

        Map<Character, Integer> map = new HashMap<>();
        PriorityQueue<entry> queue = new PriorityQueue<>((e1, e2) -> e2.freq - e1.freq);

        try {
            fr = new FileReader(fileName);
            br = new BufferedReader(fr);

            String line = null;
            while ((line = br.readLine()) != null) {
                char c = line.charAt(0);
                map.put(c, map.getOrDefault(c, 0) + 1);
            }

            for (Map.Entry<Character, Integer> entry: map.entrySet()) {
                char key = entry.getKey();
                int freq = entry.getValue();
                queue.offer(new entry(key, freq));
            }

            System.out.println(queue.size());

            while (!queue.isEmpty()) {
                entry e = queue.poll();
                System.out.println(e.value + " " + e.freq);
            }
        } catch (FileNotFoundException e) {
            System.err.println(e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (br != null) {
                br.close();
            }
            if (fr != null) {
                fr.close();
            }
        }
    }

    private static class entry {
        char value;
        int freq;
        entry(char value, int freq) {
            this.value = value;
            this.freq = freq;
        }
    }
}
