import java.io.*;
import java.util.*;

public class termFrequency {
    public static void main(String[] args) throws Exception {
        String fileName = "phrases2.txt";
        FileReader fr = null;
        BufferedReader br = null;

        Map<String, Integer> map = new HashMap<>();
        PriorityQueue<entry> queue = new PriorityQueue<>((e1, e2) -> e2.freq - e1.freq);

        try {
            fr = new FileReader(fileName);
            br = new BufferedReader(fr);

            String line = null;
            while ((line = br.readLine()) != null) {
                for (String c: line.trim().split(" ")) {
                    map.put(c, map.getOrDefault(c, 0) + 1);
                }
            }

            for (Map.Entry<String, Integer> entry: map.entrySet()) {
                String key = entry.getKey();
                int freq = entry.getValue();
                queue.offer(new entry(key, freq));
            }

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
        String value;
        int freq;
        entry(String value, int freq) {
            this.value = value;
            this.freq = freq;
        }
    }
}
